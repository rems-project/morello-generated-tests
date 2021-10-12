.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 32
.data
check_data1:
	.byte 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x03, 0x00, 0x00, 0x40, 0x51, 0x80
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x46, 0xfc, 0x9f, 0x08, 0x28, 0xb5, 0xe2, 0x22, 0x8f, 0xd5, 0xf6, 0x79, 0x39, 0x90, 0x59, 0xcb
	.byte 0x61, 0x30, 0xc2, 0xc2, 0xc2, 0x27, 0x15, 0xe2, 0x18, 0xc0, 0xd5, 0xc2, 0x3b, 0xc0, 0xfc, 0xc2
	.byte 0xfe, 0x77, 0x24, 0xc2, 0x20, 0xab, 0x53, 0x50, 0xc0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C12 */
	.octa 0xfffffffffffff000
	/* C21 */
	.octa 0x500450000000000000001
	/* C30 */
	.octa 0x80514000000300070000000000002000
final_cap_values:
	/* C0 */
	.octa 0x4a758a
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0xfffffffffffffc50
	/* C12 */
	.octa 0xfffffffffffff000
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C21 */
	.octa 0x500450000000000000001
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x80514000000300070000000000002000
initial_SP_EL3_value:
	.octa 0xffffffffffff7000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc81000004004100000ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 128
	.dword final_cap_values + 208
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x089ffc46 // stlrb:aarch64/instrs/memory/ordered Rt:6 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x22e2b528 // LDP-CC.RIAW-C Ct:8 Rn:9 Ct2:01101 imm7:1000101 L:1 001000101:001000101
	.inst 0x79f6d58f // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:15 Rn:12 imm12:110110110101 opc:11 111001:111001 size:01
	.inst 0xcb599039 // sub_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:25 Rn:1 imm6:100100 Rm:25 0:0 shift:01 01011:01011 S:0 op:1 sf:1
	.inst 0xc2c23061 // CHKTGD-C-C 00001:00001 Cn:3 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xe21527c2 // ALDURB-R.RI-32 Rt:2 Rn:30 op2:01 imm9:101010010 V:0 op1:00 11100010:11100010
	.inst 0xc2d5c018 // CVT-R.CC-C Rd:24 Cn:0 110000:110000 Cm:21 11000010110:11000010110
	.inst 0xc2fcc03b // BICFLGS-C.CI-C Cd:27 Cn:1 0:0 00:00 imm8:11100110 11000010111:11000010111
	.inst 0xc22477fe // STR-C.RIB-C Ct:30 Rn:31 imm12:100100011101 L:0 110000100:110000100
	.inst 0x5053ab20 // ADR-C.I-C Rd:0 immhi:101001110101011001 P:0 10000:10000 immlo:10 op:0
	.inst 0xc2c212c0
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400541 // ldr c1, [x10, #1]
	.inst 0xc2400942 // ldr c2, [x10, #2]
	.inst 0xc2400d43 // ldr c3, [x10, #3]
	.inst 0xc2401146 // ldr c6, [x10, #4]
	.inst 0xc2401549 // ldr c9, [x10, #5]
	.inst 0xc240194c // ldr c12, [x10, #6]
	.inst 0xc2401d55 // ldr c21, [x10, #7]
	.inst 0xc240215e // ldr c30, [x10, #8]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =initial_SP_EL3_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	ldr x10, =0x4
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032ca // ldr c10, [c22, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x826012ca // ldr c10, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x22, #0xf
	and x10, x10, x22
	cmp x10, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400156 // ldr c22, [x10, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400556 // ldr c22, [x10, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400956 // ldr c22, [x10, #2]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400d56 // ldr c22, [x10, #3]
	.inst 0xc2d6a461 // chkeq c3, c22
	b.ne comparison_fail
	.inst 0xc2401156 // ldr c22, [x10, #4]
	.inst 0xc2d6a4c1 // chkeq c6, c22
	b.ne comparison_fail
	.inst 0xc2401556 // ldr c22, [x10, #5]
	.inst 0xc2d6a501 // chkeq c8, c22
	b.ne comparison_fail
	.inst 0xc2401956 // ldr c22, [x10, #6]
	.inst 0xc2d6a521 // chkeq c9, c22
	b.ne comparison_fail
	.inst 0xc2401d56 // ldr c22, [x10, #7]
	.inst 0xc2d6a581 // chkeq c12, c22
	b.ne comparison_fail
	.inst 0xc2402156 // ldr c22, [x10, #8]
	.inst 0xc2d6a5a1 // chkeq c13, c22
	b.ne comparison_fail
	.inst 0xc2402556 // ldr c22, [x10, #9]
	.inst 0xc2d6a5e1 // chkeq c15, c22
	b.ne comparison_fail
	.inst 0xc2402956 // ldr c22, [x10, #10]
	.inst 0xc2d6a6a1 // chkeq c21, c22
	b.ne comparison_fail
	.inst 0xc2402d56 // ldr c22, [x10, #11]
	.inst 0xc2d6a701 // chkeq c24, c22
	b.ne comparison_fail
	.inst 0xc2403156 // ldr c22, [x10, #12]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	.inst 0xc2403556 // ldr c22, [x10, #13]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000011d0
	ldr x1, =check_data1
	ldr x2, =0x000011e0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001b6a
	ldr x1, =check_data2
	ldr x2, =0x00001b6c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f52
	ldr x1, =check_data3
	ldr x2, =0x00001f53
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
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
