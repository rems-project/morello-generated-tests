.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0xe1, 0xbb, 0x9f, 0x62, 0x98, 0xd1, 0x68, 0x37
.data
check_data3:
	.byte 0x97, 0xdd, 0x6e, 0xd8, 0xe1, 0xca, 0xae, 0xb0, 0x01, 0x05, 0xa1, 0x9b, 0xed, 0xb5, 0xf9, 0x54
	.byte 0x18, 0x30, 0xc0, 0xc2, 0x4f, 0x88, 0x19, 0xc2, 0xfc, 0x64, 0x91, 0xe2, 0xf5, 0x09, 0xc0, 0xda
	.byte 0xa0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x43011ffa0003ffffffffe000
	/* C1 */
	.octa 0x4000000000000000000000000000
	/* C2 */
	.octa 0x4000000000030007ffffffffffffb060
	/* C7 */
	.octa 0x4000ee
	/* C14 */
	.octa 0x40000000
	/* C15 */
	.octa 0x0
	/* C24 */
	.octa 0x2000
final_cap_values:
	/* C0 */
	.octa 0x43011ffa0003ffffffffe000
	/* C2 */
	.octa 0x4000000000030007ffffffffffffb060
	/* C7 */
	.octa 0x4000ee
	/* C14 */
	.octa 0x40000000
	/* C15 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C24 */
	.octa 0x2307
	/* C28 */
	.octa 0x3768d198
initial_csp_value:
	.octa 0x4c000000000100070000000000001110
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000003000700ffe00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x629fbbe1 // STP-C.RIBW-C Ct:1 Rn:31 Ct2:01110 imm7:0111111 L:0 011000101:011000101
	.inst 0x3768d198 // tbnz:aarch64/instrs/branch/conditional/test Rt:24 imm14:00011010001100 b40:01101 op:1 011011:011011 b5:0
	.zero 6700
	.inst 0xd86edd97 // prfm_lit:aarch64/instrs/memory/literal/general Rt:23 imm19:0110111011011101100 011000:011000 opc:11
	.inst 0xb0aecae1 // ADRP-C.I-C Rd:1 immhi:010111011001010111 P:1 10000:10000 immlo:01 op:1
	.inst 0x9ba10501 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:1 Rn:8 Ra:1 o0:0 Rm:1 01:01 U:1 10011011:10011011
	.inst 0x54f9b5ed // b_cond:aarch64/instrs/branch/conditional/cond cond:1101 0:0 imm19:1111100110110101111 01010100:01010100
	.inst 0xc2c03018 // GCLEN-R.C-C Rd:24 Cn:0 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0xc219884f // STR-C.RIB-C Ct:15 Rn:2 imm12:011001100010 L:0 110000100:110000100
	.inst 0xe29164fc // ALDUR-R.RI-32 Rt:28 Rn:7 op2:01 imm9:100010110 V:0 op1:10 11100010:11100010
	.inst 0xdac009f5 // rev:aarch64/instrs/integer/arithmetic/rev Rd:21 Rn:15 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2c211a0
	.zero 1041832
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x3, cptr_el3
	orr x3, x3, #0x200
	msr cptr_el3, x3
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400461 // ldr c1, [x3, #1]
	.inst 0xc2400862 // ldr c2, [x3, #2]
	.inst 0xc2400c67 // ldr c7, [x3, #3]
	.inst 0xc240106e // ldr c14, [x3, #4]
	.inst 0xc240146f // ldr c15, [x3, #5]
	.inst 0xc2401878 // ldr c24, [x3, #6]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =initial_csp_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2c1d07f // cpy c31, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	ldr x3, =0x0
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031a3 // ldr c3, [c13, #3]
	.inst 0xc28b4123 // msr ddc_el3, c3
	isb
	.inst 0x826011a3 // ldr c3, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr ddc_el3, c3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x13, #0xd
	and x3, x3, x13
	cmp x3, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240006d // ldr c13, [x3, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240046d // ldr c13, [x3, #1]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc240086d // ldr c13, [x3, #2]
	.inst 0xc2cda4e1 // chkeq c7, c13
	b.ne comparison_fail
	.inst 0xc2400c6d // ldr c13, [x3, #3]
	.inst 0xc2cda5c1 // chkeq c14, c13
	b.ne comparison_fail
	.inst 0xc240106d // ldr c13, [x3, #4]
	.inst 0xc2cda5e1 // chkeq c15, c13
	b.ne comparison_fail
	.inst 0xc240146d // ldr c13, [x3, #5]
	.inst 0xc2cda6a1 // chkeq c21, c13
	b.ne comparison_fail
	.inst 0xc240186d // ldr c13, [x3, #6]
	.inst 0xc2cda701 // chkeq c24, c13
	b.ne comparison_fail
	.inst 0xc2401c6d // ldr c13, [x3, #7]
	.inst 0xc2cda781 // chkeq c28, c13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001500
	ldr x1, =check_data0
	ldr x2, =0x00001520
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001680
	ldr x1, =check_data1
	ldr x2, =0x00001690
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400008
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00401a34
	ldr x1, =check_data3
	ldr x2, =0x00401a58
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
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr ddc_el3, c3
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
