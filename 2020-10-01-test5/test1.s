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
	.zero 8
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0xe1, 0x33, 0xc2, 0xc2, 0x7f, 0xfc, 0x9f, 0x48, 0xff, 0x7b, 0x57, 0x69, 0x24, 0x02, 0x59, 0xba
	.byte 0x00, 0x58, 0x53, 0xf8, 0x41, 0x69, 0x12, 0xf8, 0x41, 0xcc, 0x44, 0xe2, 0x2a, 0xdd, 0xec, 0x69
	.byte 0xfd, 0x03, 0x1f, 0x7a, 0x1f, 0x00, 0x1e, 0x1a, 0x00, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x10cb
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x80000000000100050000000000001000
	/* C3 */
	.octa 0x1000
	/* C9 */
	.octa 0x200c
	/* C10 */
	.octa 0x1fe2
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x80000000000100050000000000001000
	/* C3 */
	.octa 0x1000
	/* C9 */
	.octa 0x1f70
	/* C10 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0xffffffff
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0x1010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002000c0400000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000401200200000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 32
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c233e1 // CHKTGD-C-C 00001:00001 Cn:31 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x489ffc7f // stlrh:aarch64/instrs/memory/ordered Rt:31 Rn:3 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x69577bff // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:31 Rn:31 Rt2:11110 imm7:0101110 L:1 1010010:1010010 opc:01
	.inst 0xba590224 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0100 0:0 Rn:17 00:00 cond:0000 Rm:25 111010010:111010010 op:0 sf:1
	.inst 0xf8535800 // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:0 10:10 imm9:100110101 0:0 opc:01 111000:111000 size:11
	.inst 0xf8126941 // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:10 10:10 imm9:100100110 0:0 opc:00 111000:111000 size:11
	.inst 0xe244cc41 // ALDURSH-R.RI-32 Rt:1 Rn:2 op2:11 imm9:001001100 V:0 op1:01 11100010:11100010
	.inst 0x69ecdd2a // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:10 Rn:9 Rt2:10111 imm7:1011001 L:1 1010011:1010011 opc:01
	.inst 0x7a1f03fd // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:29 Rn:31 000000:000000 Rm:31 11010000:11010000 S:1 op:1 sf:0
	.inst 0x1a1e001f // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:0 000000:000000 Rm:30 11010000:11010000 S:0 op:0 sf:0
	.inst 0xc2c21200
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x22, cptr_el3
	orr x22, x22, #0x200
	msr cptr_el3, x22
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c1 // ldr c1, [x22, #1]
	.inst 0xc2400ac2 // ldr c2, [x22, #2]
	.inst 0xc2400ec3 // ldr c3, [x22, #3]
	.inst 0xc24012c9 // ldr c9, [x22, #4]
	.inst 0xc24016ca // ldr c10, [x22, #5]
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =initial_csp_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2c1d2df // cpy c31, c22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30850038
	msr SCTLR_EL3, x22
	ldr x22, =0x4
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82603216 // ldr c22, [c16, #3]
	.inst 0xc28b4136 // msr ddc_el3, c22
	isb
	.inst 0x82601216 // ldr c22, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr ddc_el3, c22
	isb
	/* Check processor flags */
	mrs x22, nzcv
	ubfx x22, x22, #28, #4
	mov x16, #0xf
	and x22, x22, x16
	cmp x22, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002d0 // ldr c16, [x22, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc24006d0 // ldr c16, [x22, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400ad0 // ldr c16, [x22, #2]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400ed0 // ldr c16, [x22, #3]
	.inst 0xc2d0a461 // chkeq c3, c16
	b.ne comparison_fail
	.inst 0xc24012d0 // ldr c16, [x22, #4]
	.inst 0xc2d0a521 // chkeq c9, c16
	b.ne comparison_fail
	.inst 0xc24016d0 // ldr c16, [x22, #5]
	.inst 0xc2d0a541 // chkeq c10, c16
	b.ne comparison_fail
	.inst 0xc2401ad0 // ldr c16, [x22, #6]
	.inst 0xc2d0a6e1 // chkeq c23, c16
	b.ne comparison_fail
	.inst 0xc2401ed0 // ldr c16, [x22, #7]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	.inst 0xc24022d0 // ldr c16, [x22, #8]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001020
	ldr x1, =check_data0
	ldr x2, =0x00001028
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000104c
	ldr x1, =check_data1
	ldr x2, =0x0000104e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010e8
	ldr x1, =check_data2
	ldr x2, =0x000010f0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f28
	ldr x1, =check_data3
	ldr x2, =0x00001f30
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f90
	ldr x1, =check_data4
	ldr x2, =0x00001f98
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr ddc_el3, c22
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
