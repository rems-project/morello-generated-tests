.section data0, #alloc, #write
	.zero 1648
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x08, 0x00, 0x00
	.zero 2432
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x02, 0x02
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x08, 0x00, 0x00
.data
check_data3:
	.byte 0xa0, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0x01, 0x50, 0xaf, 0x02, 0x1d, 0x14, 0xd2, 0x22, 0xff, 0x0b, 0xdc, 0xc2, 0x1f, 0x09, 0x8d, 0x90
	.byte 0x6e, 0x73, 0x42, 0xba, 0xe5, 0x87, 0x64, 0xe2, 0xa7, 0x26, 0x05, 0xfc, 0x3e, 0x87, 0x2d, 0x31
	.byte 0x00, 0xec, 0x0d, 0xa8, 0x2f, 0x2c, 0xcb, 0x79, 0xc0, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000520070000000000001660
	/* C21 */
	.octa 0x1000
	/* C27 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x18a0
	/* C1 */
	.octa 0x800000520070000000000000a8c
	/* C5 */
	.octa 0x880000000000000000000000000
	/* C15 */
	.octa 0x0
	/* C21 */
	.octa 0x1052
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x0
initial_csp_value:
	.octa 0x80000000620020010000000000401fc0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000000600070000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001660
	.dword 0x0000000000001670
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x02af5001 // SUB-C.CIS-C Cd:1 Cn:0 imm12:101111010100 sh:0 A:1 00000010:00000010
	.inst 0x22d2141d // LDP-CC.RIAW-C Ct:29 Rn:0 Ct2:00101 imm7:0100100 L:1 001000101:001000101
	.inst 0xc2dc0bff // SEAL-C.CC-C Cd:31 Cn:31 0010:0010 opc:00 Cm:28 11000010110:11000010110
	.inst 0x908d091f // ADRP-C.IP-C Rd:31 immhi:000110100001001000 P:1 10000:10000 immlo:00 op:1
	.inst 0xba42736e // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1110 0:0 Rn:27 00:00 cond:0111 Rm:2 111010010:111010010 op:0 sf:1
	.inst 0xe26487e5 // ALDUR-V.RI-H Rt:5 Rn:31 op2:01 imm9:001001000 V:1 op1:01 11100010:11100010
	.inst 0xfc0526a7 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:7 Rn:21 01:01 imm9:001010010 0:0 opc:00 111100:111100 size:11
	.inst 0x312d873e // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:30 Rn:25 imm12:101101100001 sh:0 0:0 10001:10001 S:1 op:0 sf:0
	.inst 0xa80dec00 // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:0 Rn:0 Rt2:11011 imm7:0011011 L:0 1010000:1010000 opc:10
	.inst 0x79cb2c2f // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:15 Rn:1 imm12:001011001011 opc:11 111001:111001 size:01
	.inst 0xc2c211c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x10, cptr_el3
	orr x10, x10, #0x200
	msr cptr_el3, x10
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400555 // ldr c21, [x10, #1]
	.inst 0xc240095b // ldr c27, [x10, #2]
	/* Vector registers */
	mrs x10, cptr_el3
	bfc x10, #10, #1
	msr cptr_el3, x10
	isb
	ldr q7, =0x202002000000000
	/* Set up flags and system registers */
	mov x10, #0x10000000
	msr nzcv, x10
	ldr x10, =initial_csp_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30850038
	msr SCTLR_EL3, x10
	ldr x10, =0xc
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031ca // ldr c10, [c14, #3]
	.inst 0xc28b412a // msr ddc_el3, c10
	isb
	.inst 0x826011ca // ldr c10, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr ddc_el3, c10
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc240014e // ldr c14, [x10, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc240054e // ldr c14, [x10, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc240094e // ldr c14, [x10, #2]
	.inst 0xc2cea4a1 // chkeq c5, c14
	b.ne comparison_fail
	.inst 0xc2400d4e // ldr c14, [x10, #3]
	.inst 0xc2cea5e1 // chkeq c15, c14
	b.ne comparison_fail
	.inst 0xc240114e // ldr c14, [x10, #4]
	.inst 0xc2cea6a1 // chkeq c21, c14
	b.ne comparison_fail
	.inst 0xc240154e // ldr c14, [x10, #5]
	.inst 0xc2cea761 // chkeq c27, c14
	b.ne comparison_fail
	.inst 0xc240194e // ldr c14, [x10, #6]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x10, =0x0
	mov x14, v5.d[0]
	cmp x10, x14
	b.ne comparison_fail
	ldr x10, =0x0
	mov x14, v5.d[1]
	cmp x10, x14
	b.ne comparison_fail
	ldr x10, =0x202002000000000
	mov x14, v7.d[0]
	cmp x10, x14
	b.ne comparison_fail
	ldr x10, =0x0
	mov x14, v7.d[1]
	cmp x10, x14
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
	ldr x0, =0x00001022
	ldr x1, =check_data1
	ldr x2, =0x00001024
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001660
	ldr x1, =check_data2
	ldr x2, =0x00001680
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001978
	ldr x1, =check_data3
	ldr x2, =0x00001988
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
	ldr x0, =0x00402008
	ldr x1, =check_data5
	ldr x2, =0x0040200a
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
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr ddc_el3, c10
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
