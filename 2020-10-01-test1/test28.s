.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x40, 0x00, 0x40, 0x00, 0x40
.data
check_data3:
	.byte 0xed, 0x1a, 0xc1, 0x8a, 0x97, 0x02, 0x1e, 0x1a, 0x01, 0xff, 0xdf, 0x08, 0x3e, 0x28, 0xc8, 0x9a
	.byte 0x3d, 0xeb, 0x5c, 0xf9, 0x82, 0x7f, 0x3f, 0x42, 0x00, 0x04, 0x9e, 0x1a, 0xe2, 0x73, 0x10, 0x62
	.byte 0x5a, 0xfc, 0x9f, 0x08, 0x3e, 0xc9, 0xf4, 0x28, 0x60, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x4000000000000000000000001000
	/* C9 */
	.octa 0x1004
	/* C24 */
	.octa 0x4feff8
	/* C25 */
	.octa 0x3fc630
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x40004000400000040000000000001000
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x4000000000000000000000001000
	/* C9 */
	.octa 0xfa8
	/* C18 */
	.octa 0x0
	/* C24 */
	.octa 0x4feff8
	/* C25 */
	.octa 0x3fc630
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x40004000400000040000000000001000
	/* C29 */
	.octa 0x1a1e02978ac11aed
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0x1010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000580100000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc8000000000600060000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x8ac11aed // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:13 Rn:23 imm6:000110 Rm:1 N:0 shift:11 01010:01010 opc:00 sf:1
	.inst 0x1a1e0297 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:23 Rn:20 000000:000000 Rm:30 11010000:11010000 S:0 op:0 sf:0
	.inst 0x08dfff01 // ldarb:aarch64/instrs/memory/ordered Rt:1 Rn:24 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x9ac8283e // asrv:aarch64/instrs/integer/shift/variable Rd:30 Rn:1 op2:10 0010:0010 Rm:8 0011010110:0011010110 sf:1
	.inst 0xf95ceb3d // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:29 Rn:25 imm12:011100111010 opc:01 111001:111001 size:11
	.inst 0x423f7f82 // ASTLRB-R.R-B Rt:2 Rn:28 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x1a9e0400 // csinc:aarch64/instrs/integer/conditional/select Rd:0 Rn:0 o2:1 0:0 cond:0000 Rm:30 011010100:011010100 op:0 sf:0
	.inst 0x621073e2 // STNP-C.RIB-C Ct:2 Rn:31 Ct2:11100 imm7:0100000 L:0 011000100:011000100
	.inst 0x089ffc5a // stlrb:aarch64/instrs/memory/ordered Rt:26 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x28f4c93e // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:30 Rn:9 Rt2:10010 imm7:1101001 L:1 1010001:1010001 opc:00
	.inst 0xc2c21160
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a2 // ldr c2, [x5, #0]
	.inst 0xc24004a9 // ldr c9, [x5, #1]
	.inst 0xc24008b8 // ldr c24, [x5, #2]
	.inst 0xc2400cb9 // ldr c25, [x5, #3]
	.inst 0xc24010ba // ldr c26, [x5, #4]
	.inst 0xc24014bc // ldr c28, [x5, #5]
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =initial_csp_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2c1d0bf // cpy c31, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	ldr x5, =0x0
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82603165 // ldr c5, [c11, #3]
	.inst 0xc28b4125 // msr ddc_el3, c5
	isb
	.inst 0x82601165 // ldr c5, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr ddc_el3, c5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x11, #0x4
	and x5, x5, x11
	cmp x5, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000ab // ldr c11, [x5, #0]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc24004ab // ldr c11, [x5, #1]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc24008ab // ldr c11, [x5, #2]
	.inst 0xc2cba521 // chkeq c9, c11
	b.ne comparison_fail
	.inst 0xc2400cab // ldr c11, [x5, #3]
	.inst 0xc2cba641 // chkeq c18, c11
	b.ne comparison_fail
	.inst 0xc24010ab // ldr c11, [x5, #4]
	.inst 0xc2cba701 // chkeq c24, c11
	b.ne comparison_fail
	.inst 0xc24014ab // ldr c11, [x5, #5]
	.inst 0xc2cba721 // chkeq c25, c11
	b.ne comparison_fail
	.inst 0xc24018ab // ldr c11, [x5, #6]
	.inst 0xc2cba741 // chkeq c26, c11
	b.ne comparison_fail
	.inst 0xc2401cab // ldr c11, [x5, #7]
	.inst 0xc2cba781 // chkeq c28, c11
	b.ne comparison_fail
	.inst 0xc24020ab // ldr c11, [x5, #8]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc24024ab // ldr c11, [x5, #9]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001004
	ldr x1, =check_data1
	ldr x2, =0x0000100c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001210
	ldr x1, =check_data2
	ldr x2, =0x00001230
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
	ldr x0, =0x004feff8
	ldr x1, =check_data4
	ldr x2, =0x004feff9
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
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr ddc_el3, c5
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
