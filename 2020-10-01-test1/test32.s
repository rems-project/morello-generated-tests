.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 32
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x7e, 0x3d, 0x55, 0xa2, 0xa9, 0xb4, 0x5c, 0xfc, 0x7e, 0x09, 0xda, 0x1a, 0x41, 0xb0, 0xc5, 0xc2
	.byte 0x60, 0x63, 0x4a, 0x38, 0xe0, 0x93, 0xc5, 0xc2, 0xf1, 0xbc, 0x3f, 0xad, 0x1f, 0x70, 0x1f, 0xb1
	.byte 0x36, 0xcf, 0xd8, 0x28, 0x20, 0x15, 0x18, 0xa2, 0x40, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x2300021
	/* C5 */
	.octa 0x800000005206020f0000000000001000
	/* C7 */
	.octa 0x40000000400000190000000000001020
	/* C9 */
	.octa 0x400000000001000500000000000010a0
	/* C11 */
	.octa 0x801000000005000700000000000020e0
	/* C25 */
	.octa 0x800000001007a00b00000000004e0004
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x80000000100140050000000000001f00
final_cap_values:
	/* C0 */
	.octa 0x700000000000000000000
	/* C1 */
	.octa 0x20008000014100070000000002300021
	/* C2 */
	.octa 0x2300021
	/* C5 */
	.octa 0x800000005206020f0000000000000fcb
	/* C7 */
	.octa 0x40000000400000190000000000001020
	/* C9 */
	.octa 0x400000000001000500000000000008b0
	/* C11 */
	.octa 0x80100000000500070000000000001610
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0x800000001007a00b00000000004e00c8
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x80000000100140050000000000001f00
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000014100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x700000000000000818000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001610
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword final_cap_values + 176
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2553d7e // LDR-C.RIBW-C Ct:30 Rn:11 11:11 imm9:101010011 0:0 opc:01 10100010:10100010
	.inst 0xfc5cb4a9 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:9 Rn:5 01:01 imm9:111001011 0:0 opc:01 111100:111100 size:11
	.inst 0x1ada097e // udiv:aarch64/instrs/integer/arithmetic/div Rd:30 Rn:11 o1:0 00001:00001 Rm:26 0011010110:0011010110 sf:0
	.inst 0xc2c5b041 // CVTP-C.R-C Cd:1 Rn:2 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x384a6360 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:27 00:00 imm9:010100110 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c593e0 // CVTD-C.R-C Cd:0 Rn:31 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xad3fbcf1 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:17 Rn:7 Rt2:01111 imm7:1111111 L:0 1011010:1011010 opc:10
	.inst 0xb11f701f // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:0 imm12:011111011100 sh:0 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0x28d8cf36 // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:22 Rn:25 Rt2:10011 imm7:0110001 L:1 1010001:1010001 opc:00
	.inst 0xa2181520 // STR-C.RIAW-C Ct:0 Rn:9 01:01 imm9:110000001 0:0 opc:00 10100010:10100010
	.inst 0xc2c21140
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x15, cptr_el3
	orr x15, x15, #0x200
	msr cptr_el3, x15
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e2 // ldr c2, [x15, #0]
	.inst 0xc24005e5 // ldr c5, [x15, #1]
	.inst 0xc24009e7 // ldr c7, [x15, #2]
	.inst 0xc2400de9 // ldr c9, [x15, #3]
	.inst 0xc24011eb // ldr c11, [x15, #4]
	.inst 0xc24015f9 // ldr c25, [x15, #5]
	.inst 0xc24019fa // ldr c26, [x15, #6]
	.inst 0xc2401dfb // ldr c27, [x15, #7]
	/* Vector registers */
	mrs x15, cptr_el3
	bfc x15, #10, #1
	msr cptr_el3, x15
	isb
	ldr q15, =0x0
	ldr q17, =0x0
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	ldr x15, =0x8
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x8260314f // ldr c15, [c10, #3]
	.inst 0xc28b412f // msr ddc_el3, c15
	isb
	.inst 0x8260114f // ldr c15, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr ddc_el3, c15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x10, #0xf
	and x15, x15, x10
	cmp x15, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001ea // ldr c10, [x15, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24005ea // ldr c10, [x15, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc24009ea // ldr c10, [x15, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400dea // ldr c10, [x15, #3]
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	.inst 0xc24011ea // ldr c10, [x15, #4]
	.inst 0xc2caa4e1 // chkeq c7, c10
	b.ne comparison_fail
	.inst 0xc24015ea // ldr c10, [x15, #5]
	.inst 0xc2caa521 // chkeq c9, c10
	b.ne comparison_fail
	.inst 0xc24019ea // ldr c10, [x15, #6]
	.inst 0xc2caa561 // chkeq c11, c10
	b.ne comparison_fail
	.inst 0xc2401dea // ldr c10, [x15, #7]
	.inst 0xc2caa661 // chkeq c19, c10
	b.ne comparison_fail
	.inst 0xc24021ea // ldr c10, [x15, #8]
	.inst 0xc2caa6c1 // chkeq c22, c10
	b.ne comparison_fail
	.inst 0xc24025ea // ldr c10, [x15, #9]
	.inst 0xc2caa721 // chkeq c25, c10
	b.ne comparison_fail
	.inst 0xc24029ea // ldr c10, [x15, #10]
	.inst 0xc2caa741 // chkeq c26, c10
	b.ne comparison_fail
	.inst 0xc2402dea // ldr c10, [x15, #11]
	.inst 0xc2caa761 // chkeq c27, c10
	b.ne comparison_fail
	.inst 0xc24031ea // ldr c10, [x15, #12]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x0
	mov x10, v9.d[0]
	cmp x15, x10
	b.ne comparison_fail
	ldr x15, =0x0
	mov x10, v9.d[1]
	cmp x15, x10
	b.ne comparison_fail
	ldr x15, =0x0
	mov x10, v15.d[0]
	cmp x15, x10
	b.ne comparison_fail
	ldr x15, =0x0
	mov x10, v15.d[1]
	cmp x15, x10
	b.ne comparison_fail
	ldr x15, =0x0
	mov x10, v17.d[0]
	cmp x15, x10
	b.ne comparison_fail
	ldr x15, =0x0
	mov x10, v17.d[1]
	cmp x15, x10
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
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001030
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010a0
	ldr x1, =check_data2
	ldr x2, =0x000010b0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001610
	ldr x1, =check_data3
	ldr x2, =0x00001620
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fa6
	ldr x1, =check_data4
	ldr x2, =0x00001fa7
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
	ldr x0, =0x004e0004
	ldr x1, =check_data6
	ldr x2, =0x004e000c
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
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr ddc_el3, c15
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
