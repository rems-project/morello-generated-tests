.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x22, 0x87, 0xca, 0xe2, 0xdd, 0xa3, 0xde, 0xc2, 0x76, 0x87, 0x59, 0xfc, 0xcb, 0xc3, 0x83, 0x1a
	.byte 0xa1, 0x32, 0xc2, 0xc2, 0x92, 0xd8, 0x57, 0x82, 0xfe, 0x4f, 0x2c, 0xc2, 0x03, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0xbf, 0x12, 0xc5, 0xc2, 0x5f, 0x33, 0x03, 0xd5, 0xc0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C4 */
	.octa 0x1000
	/* C8 */
	.octa 0x200000000007800700000000004087e8
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C25 */
	.octa 0x1800
	/* C27 */
	.octa 0x80000000000000200000000000401040
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x1000
	/* C8 */
	.octa 0x200000000007800700000000004087e8
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C25 */
	.octa 0x1800
	/* C27 */
	.octa 0x80000000000000200000000000400fd8
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x4000000000030007ffffffffffff5f00
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000f8700070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000180050000001000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2ca8722 // ALDUR-R.RI-64 Rt:2 Rn:25 op2:01 imm9:010101000 V:0 op1:11 11100010:11100010
	.inst 0xc2dea3dd // CLRPERM-C.CR-C Cd:29 Cn:30 000:000 1:1 10:10 Rm:30 11000010110:11000010110
	.inst 0xfc598776 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:22 Rn:27 01:01 imm9:110011000 0:0 opc:01 111100:111100 size:11
	.inst 0x1a83c3cb // csel:aarch64/instrs/integer/conditional/select Rd:11 Rn:30 o2:0 0:0 cond:1100 Rm:3 011010100:011010100 op:0 sf:0
	.inst 0xc2c232a1 // CHKTGD-C-C 00001:00001 Cn:21 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x8257d892 // ASTR-R.RI-32 Rt:18 Rn:4 op:10 imm9:101111101 L:0 1000001001:1000001001
	.inst 0xc22c4ffe // STR-C.RIB-C Ct:30 Rn:31 imm12:101100010011 L:0 110000100:110000100
	.inst 0xc2c21103 // BRR-C-C 00011:00011 Cn:8 100:100 opc:00 11000010110000100:11000010110000100
	.zero 34760
	.inst 0xc2c512bf // CVTD-R.C-C Rd:31 Cn:21 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0xd503335f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:0011 11010101000000110011:11010101000000110011
	.inst 0xc2c212c0
	.zero 1013772
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x19, cptr_el3
	orr x19, x19, #0x200
	msr cptr_el3, x19
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
	ldr x19, =initial_cap_values
	.inst 0xc2400264 // ldr c4, [x19, #0]
	.inst 0xc2400668 // ldr c8, [x19, #1]
	.inst 0xc2400a72 // ldr c18, [x19, #2]
	.inst 0xc2400e75 // ldr c21, [x19, #3]
	.inst 0xc2401279 // ldr c25, [x19, #4]
	.inst 0xc240167b // ldr c27, [x19, #5]
	.inst 0xc2401a7e // ldr c30, [x19, #6]
	/* Set up flags and system registers */
	mov x19, #0x80000000
	msr nzcv, x19
	ldr x19, =initial_SP_EL3_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30850038
	msr SCTLR_EL3, x19
	ldr x19, =0x0
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032d3 // ldr c19, [c22, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x826012d3 // ldr c19, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x22, #0xf
	and x19, x19, x22
	cmp x19, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400276 // ldr c22, [x19, #0]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400676 // ldr c22, [x19, #1]
	.inst 0xc2d6a481 // chkeq c4, c22
	b.ne comparison_fail
	.inst 0xc2400a76 // ldr c22, [x19, #2]
	.inst 0xc2d6a501 // chkeq c8, c22
	b.ne comparison_fail
	.inst 0xc2400e76 // ldr c22, [x19, #3]
	.inst 0xc2d6a641 // chkeq c18, c22
	b.ne comparison_fail
	.inst 0xc2401276 // ldr c22, [x19, #4]
	.inst 0xc2d6a6a1 // chkeq c21, c22
	b.ne comparison_fail
	.inst 0xc2401676 // ldr c22, [x19, #5]
	.inst 0xc2d6a721 // chkeq c25, c22
	b.ne comparison_fail
	.inst 0xc2401a76 // ldr c22, [x19, #6]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	.inst 0xc2401e76 // ldr c22, [x19, #7]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2402276 // ldr c22, [x19, #8]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x0
	mov x22, v22.d[0]
	cmp x19, x22
	b.ne comparison_fail
	ldr x19, =0x0
	mov x22, v22.d[1]
	cmp x19, x22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001030
	ldr x1, =check_data0
	ldr x2, =0x00001040
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000015f4
	ldr x1, =check_data1
	ldr x2, =0x000015f8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000018a8
	ldr x1, =check_data2
	ldr x2, =0x000018b0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400020
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00401040
	ldr x1, =check_data4
	ldr x2, =0x00401048
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004087e8
	ldr x1, =check_data5
	ldr x2, =0x004087f4
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
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
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
