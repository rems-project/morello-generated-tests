.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x41, 0x44, 0x19, 0x3c, 0xc1, 0x5f, 0xe2, 0xc2, 0xf4, 0x7b, 0xdb, 0xa9, 0x02, 0x24, 0x94, 0xe2
	.byte 0xc1, 0x96, 0xed, 0x36, 0xf9, 0x8b, 0x5e, 0x38, 0x20, 0x9f, 0xb3, 0xf0, 0x70, 0x1e, 0x1e, 0xb8
	.byte 0x8b, 0x63, 0x9b, 0x82, 0xdf, 0x0f, 0x1d, 0x71, 0xc0, 0x11, 0xc2, 0xc2
.data
check_data6:
	.byte 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data7:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x500006
	/* C2 */
	.octa 0x4000000000010007000000000000102c
	/* C11 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C19 */
	.octa 0x40000000001600170000000000002007
	/* C27 */
	.octa 0x1abbbe5b4f141000
	/* C28 */
	.octa 0xe54441a4b0ec0000
	/* C30 */
	.octa 0x400400
final_cap_values:
	/* C0 */
	.octa 0x200080000009000700000000677e7000
	/* C1 */
	.octa 0x20000000
	/* C2 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C19 */
	.octa 0x40000000001600170000000000001fe8
	/* C20 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C27 */
	.octa 0x1abbbe5b4f141000
	/* C28 */
	.octa 0xe54441a4b0ec0000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x80000000326100070000000000000f00
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000900070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0100000000300070000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3c194441 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:1 Rn:2 01:01 imm9:110010100 0:0 opc:00 111100:111100 size:00
	.inst 0xc2e25fc1 // ALDR-C.RRB-C Ct:1 Rn:30 1:1 L:1 S:1 option:010 Rm:2 11000010111:11000010111
	.inst 0xa9db7bf4 // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:20 Rn:31 Rt2:11110 imm7:0110110 L:1 1010011:1010011 opc:10
	.inst 0xe2942402 // ALDUR-R.RI-32 Rt:2 Rn:0 op2:01 imm9:101000010 V:0 op1:10 11100010:11100010
	.inst 0x36ed96c1 // tbz:aarch64/instrs/branch/conditional/test Rt:1 imm14:10110010110110 b40:11101 op:0 011011:011011 b5:0
	.inst 0x385e8bf9 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:25 Rn:31 10:10 imm9:111101000 0:0 opc:01 111000:111000 size:00
	.inst 0xf0b39f20 // ADRP-C.IP-C Rd:0 immhi:011001110011111001 P:1 10000:10000 immlo:11 op:1
	.inst 0xb81e1e70 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:16 Rn:19 11:11 imm9:111100001 0:0 opc:00 111000:111000 size:10
	.inst 0x829b638b // ASTRB-R.RRB-B Rt:11 Rn:28 opc:00 S:0 option:011 Rm:27 0:0 L:0 100000101:100000101
	.inst 0x711d0fdf // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:30 imm12:011101000011 sh:0 0:0 10001:10001 S:1 op:1 sf:0
	.inst 0xc2c211c0
	.zero 65492
	.inst 0x20000000
	.zero 983036
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c2 // ldr c2, [x22, #1]
	.inst 0xc2400acb // ldr c11, [x22, #2]
	.inst 0xc2400ed0 // ldr c16, [x22, #3]
	.inst 0xc24012d3 // ldr c19, [x22, #4]
	.inst 0xc24016db // ldr c27, [x22, #5]
	.inst 0xc2401adc // ldr c28, [x22, #6]
	.inst 0xc2401ede // ldr c30, [x22, #7]
	/* Vector registers */
	mrs x22, cptr_el3
	bfc x22, #10, #1
	msr cptr_el3, x22
	isb
	ldr q1, =0x0
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =initial_SP_EL3_value
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
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031d6 // ldr c22, [c14, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x826011d6 // ldr c22, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	/* Check processor flags */
	mrs x22, nzcv
	ubfx x22, x22, #28, #4
	mov x14, #0xf
	and x22, x22, x14
	cmp x22, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002ce // ldr c14, [x22, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc24006ce // ldr c14, [x22, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc2400ace // ldr c14, [x22, #2]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc2400ece // ldr c14, [x22, #3]
	.inst 0xc2cea561 // chkeq c11, c14
	b.ne comparison_fail
	.inst 0xc24012ce // ldr c14, [x22, #4]
	.inst 0xc2cea601 // chkeq c16, c14
	b.ne comparison_fail
	.inst 0xc24016ce // ldr c14, [x22, #5]
	.inst 0xc2cea661 // chkeq c19, c14
	b.ne comparison_fail
	.inst 0xc2401ace // ldr c14, [x22, #6]
	.inst 0xc2cea681 // chkeq c20, c14
	b.ne comparison_fail
	.inst 0xc2401ece // ldr c14, [x22, #7]
	.inst 0xc2cea721 // chkeq c25, c14
	b.ne comparison_fail
	.inst 0xc24022ce // ldr c14, [x22, #8]
	.inst 0xc2cea761 // chkeq c27, c14
	b.ne comparison_fail
	.inst 0xc24026ce // ldr c14, [x22, #9]
	.inst 0xc2cea781 // chkeq c28, c14
	b.ne comparison_fail
	.inst 0xc2402ace // ldr c14, [x22, #10]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x22, =0x0
	mov x14, v1.d[0]
	cmp x22, x14
	b.ne comparison_fail
	ldr x22, =0x0
	mov x14, v1.d[1]
	cmp x22, x14
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
	ldr x0, =0x0000102c
	ldr x1, =check_data1
	ldr x2, =0x0000102d
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001098
	ldr x1, =check_data2
	ldr x2, =0x00001099
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010b0
	ldr x1, =check_data3
	ldr x2, =0x000010c0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fe8
	ldr x1, =check_data4
	ldr x2, =0x00001fec
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
	ldr x0, =0x00410000
	ldr x1, =check_data6
	ldr x2, =0x00410010
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004fff48
	ldr x1, =check_data7
	ldr x2, =0x004fff4c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
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
