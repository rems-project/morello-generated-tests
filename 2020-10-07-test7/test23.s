.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x49, 0x9e, 0xd9, 0xc2, 0xc4, 0xdf, 0x22, 0xe2, 0x56, 0x0c, 0xde, 0x9a, 0xe0, 0x73, 0xc2, 0xc2
	.byte 0x03, 0xc4, 0x13, 0x38, 0x39, 0x10, 0xb5, 0xb9, 0x9f, 0x8b, 0x1b, 0x1b, 0xc4, 0x64, 0xd0, 0xc2
	.byte 0x81, 0x46, 0x58, 0x78, 0x01, 0x7e, 0x48, 0x78, 0xa0, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x780
	/* C1 */
	.octa 0xffffffffffffcffd
	/* C3 */
	.octa 0x0
	/* C6 */
	.octa 0xa00120070000000000000001
	/* C16 */
	.octa 0x0
	/* C20 */
	.octa 0x401
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x6bc
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0xa00120070000000000000000
	/* C6 */
	.octa 0xa00120070000000000000001
	/* C16 */
	.octa 0x87
	/* C20 */
	.octa 0x385
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000007000100300ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d99e49 // CSEL-C.CI-C Cd:9 Cn:18 11:11 cond:1001 Cm:25 11000010110:11000010110
	.inst 0xe222dfc4 // ALDUR-V.RI-Q Rt:4 Rn:30 op2:11 imm9:000101101 V:1 op1:00 11100010:11100010
	.inst 0x9ade0c56 // sdiv:aarch64/instrs/integer/arithmetic/div Rd:22 Rn:2 o1:1 00001:00001 Rm:30 0011010110:0011010110 sf:1
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0x3813c403 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:3 Rn:0 01:01 imm9:100111100 0:0 opc:00 111000:111000 size:00
	.inst 0xb9b51039 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:25 Rn:1 imm12:110101000100 opc:10 111001:111001 size:10
	.inst 0x1b1b8b9f // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:31 Rn:28 Ra:2 o0:1 Rm:27 0011011000:0011011000 sf:0
	.inst 0xc2d064c4 // CPYVALUE-C.C-C Cd:4 Cn:6 001:001 opc:11 0:0 Cm:16 11000010110:11000010110
	.inst 0x78584681 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:20 01:01 imm9:110000100 0:0 opc:01 111000:111000 size:01
	.inst 0x78487e01 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:16 11:11 imm9:010000111 0:0 opc:01 111000:111000 size:01
	.inst 0xc2c213a0
	.zero 1048532
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a1 // ldr c1, [x13, #1]
	.inst 0xc24009a3 // ldr c3, [x13, #2]
	.inst 0xc2400da6 // ldr c6, [x13, #3]
	.inst 0xc24011b0 // ldr c16, [x13, #4]
	.inst 0xc24015b4 // ldr c20, [x13, #5]
	.inst 0xc24019be // ldr c30, [x13, #6]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30850032
	msr SCTLR_EL3, x13
	ldr x13, =0x4
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033ad // ldr c13, [c29, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x826013ad // ldr c13, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x29, #0x2
	and x13, x13, x29
	cmp x13, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001bd // ldr c29, [x13, #0]
	.inst 0xc2dda401 // chkeq c0, c29
	b.ne comparison_fail
	.inst 0xc24005bd // ldr c29, [x13, #1]
	.inst 0xc2dda421 // chkeq c1, c29
	b.ne comparison_fail
	.inst 0xc24009bd // ldr c29, [x13, #2]
	.inst 0xc2dda461 // chkeq c3, c29
	b.ne comparison_fail
	.inst 0xc2400dbd // ldr c29, [x13, #3]
	.inst 0xc2dda481 // chkeq c4, c29
	b.ne comparison_fail
	.inst 0xc24011bd // ldr c29, [x13, #4]
	.inst 0xc2dda4c1 // chkeq c6, c29
	b.ne comparison_fail
	.inst 0xc24015bd // ldr c29, [x13, #5]
	.inst 0xc2dda601 // chkeq c16, c29
	b.ne comparison_fail
	.inst 0xc24019bd // ldr c29, [x13, #6]
	.inst 0xc2dda681 // chkeq c20, c29
	b.ne comparison_fail
	.inst 0xc2401dbd // ldr c29, [x13, #7]
	.inst 0xc2dda6c1 // chkeq c22, c29
	b.ne comparison_fail
	.inst 0xc24021bd // ldr c29, [x13, #8]
	.inst 0xc2dda721 // chkeq c25, c29
	b.ne comparison_fail
	.inst 0xc24025bd // ldr c29, [x13, #9]
	.inst 0xc2dda7c1 // chkeq c30, c29
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x29, v4.d[0]
	cmp x13, x29
	b.ne comparison_fail
	ldr x13, =0x0
	mov x29, v4.d[1]
	cmp x13, x29
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
	ldr x0, =0x0000108a
	ldr x1, =check_data1
	ldr x2, =0x0000108c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001404
	ldr x1, =check_data2
	ldr x2, =0x00001406
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001510
	ldr x1, =check_data3
	ldr x2, =0x00001514
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001783
	ldr x1, =check_data4
	ldr x2, =0x00001784
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
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
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
