.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0x3b, 0xc0, 0x5a, 0x79, 0x75, 0xf5, 0xa2, 0x82, 0x01, 0x30, 0xc5, 0xc2, 0x5e, 0xfc, 0x7f, 0x42
	.byte 0x9a, 0xe4, 0x2e, 0xeb, 0x2a, 0x64, 0x41, 0x69, 0x4c, 0x56, 0x63, 0xe2, 0xc0, 0x19, 0x44, 0xba
	.byte 0x60, 0x12, 0xc2, 0xc2
.data
check_data7:
	.byte 0x00, 0x76, 0x97, 0x3c, 0x80, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1004
	/* C1 */
	.octa 0x101c
	/* C2 */
	.octa 0x800000000001000500000000000011fc
	/* C4 */
	.octa 0x0
	/* C11 */
	.octa 0x4000000000030006ffffffffffff8020
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x400000000004000500000000000013d0
	/* C18 */
	.octa 0x80000000000100050000000000001fc1
	/* C19 */
	.octa 0x20008000800080080000000000408005
	/* C21 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x1004
	/* C1 */
	.octa 0x1004
	/* C2 */
	.octa 0x800000000001000500000000000011fc
	/* C4 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x4000000000030006ffffffffffff8020
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x40000000000400050000000000001347
	/* C18 */
	.octa 0x80000000000100050000000000001fc1
	/* C19 */
	.octa 0x20008000800080080000000000408005
	/* C21 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000007c00b0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000006000000100ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x795ac03b // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:27 Rn:1 imm12:011010110000 opc:01 111001:111001 size:01
	.inst 0x82a2f575 // ASTR-R.RRB-64 Rt:21 Rn:11 opc:01 S:1 option:111 Rm:2 1:1 L:0 100000101:100000101
	.inst 0xc2c53001 // CVTP-R.C-C Rd:1 Cn:0 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0x427ffc5e // ALDAR-R.R-32 Rt:30 Rn:2 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xeb2ee49a // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:26 Rn:4 imm3:001 option:111 Rm:14 01011001:01011001 S:1 op:1 sf:1
	.inst 0x6941642a // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:10 Rn:1 Rt2:11001 imm7:0000010 L:1 1010010:1010010 opc:01
	.inst 0xe263564c // ALDUR-V.RI-H Rt:12 Rn:18 op2:01 imm9:000110101 V:1 op1:01 11100010:11100010
	.inst 0xba4419c0 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0000 0:0 Rn:14 10:10 cond:0001 imm5:00100 111010010:111010010 op:0 sf:1
	.inst 0xc2c21260 // BR-C-C 00000:00000 Cn:19 100:100 opc:00 11000010110000100:11000010110000100
	.zero 32736
	.inst 0x3c977600 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:0 Rn:16 01:01 imm9:101110111 0:0 opc:10 111100:111100 size:00
	.inst 0xc2c21180
	.zero 1015796
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x24, cptr_el3
	orr x24, x24, #0x200
	msr cptr_el3, x24
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400701 // ldr c1, [x24, #1]
	.inst 0xc2400b02 // ldr c2, [x24, #2]
	.inst 0xc2400f04 // ldr c4, [x24, #3]
	.inst 0xc240130b // ldr c11, [x24, #4]
	.inst 0xc240170e // ldr c14, [x24, #5]
	.inst 0xc2401b10 // ldr c16, [x24, #6]
	.inst 0xc2401f12 // ldr c18, [x24, #7]
	.inst 0xc2402313 // ldr c19, [x24, #8]
	.inst 0xc2402715 // ldr c21, [x24, #9]
	/* Vector registers */
	mrs x24, cptr_el3
	bfc x24, #10, #1
	msr cptr_el3, x24
	isb
	ldr q0, =0x0
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30850032
	msr SCTLR_EL3, x24
	ldr x24, =0x0
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82603198 // ldr c24, [c12, #3]
	.inst 0xc28b4138 // msr ddc_el3, c24
	isb
	.inst 0x82601198 // ldr c24, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr ddc_el3, c24
	isb
	/* Check processor flags */
	mrs x24, nzcv
	ubfx x24, x24, #28, #4
	mov x12, #0xf
	and x24, x24, x12
	cmp x24, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc240030c // ldr c12, [x24, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240070c // ldr c12, [x24, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc2400b0c // ldr c12, [x24, #2]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400f0c // ldr c12, [x24, #3]
	.inst 0xc2cca481 // chkeq c4, c12
	b.ne comparison_fail
	.inst 0xc240130c // ldr c12, [x24, #4]
	.inst 0xc2cca541 // chkeq c10, c12
	b.ne comparison_fail
	.inst 0xc240170c // ldr c12, [x24, #5]
	.inst 0xc2cca561 // chkeq c11, c12
	b.ne comparison_fail
	.inst 0xc2401b0c // ldr c12, [x24, #6]
	.inst 0xc2cca5c1 // chkeq c14, c12
	b.ne comparison_fail
	.inst 0xc2401f0c // ldr c12, [x24, #7]
	.inst 0xc2cca601 // chkeq c16, c12
	b.ne comparison_fail
	.inst 0xc240230c // ldr c12, [x24, #8]
	.inst 0xc2cca641 // chkeq c18, c12
	b.ne comparison_fail
	.inst 0xc240270c // ldr c12, [x24, #9]
	.inst 0xc2cca661 // chkeq c19, c12
	b.ne comparison_fail
	.inst 0xc2402b0c // ldr c12, [x24, #10]
	.inst 0xc2cca6a1 // chkeq c21, c12
	b.ne comparison_fail
	.inst 0xc2402f0c // ldr c12, [x24, #11]
	.inst 0xc2cca721 // chkeq c25, c12
	b.ne comparison_fail
	.inst 0xc240330c // ldr c12, [x24, #12]
	.inst 0xc2cca741 // chkeq c26, c12
	b.ne comparison_fail
	.inst 0xc240370c // ldr c12, [x24, #13]
	.inst 0xc2cca761 // chkeq c27, c12
	b.ne comparison_fail
	.inst 0xc2403b0c // ldr c12, [x24, #14]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x0
	mov x12, v0.d[0]
	cmp x24, x12
	b.ne comparison_fail
	ldr x24, =0x0
	mov x12, v0.d[1]
	cmp x24, x12
	b.ne comparison_fail
	ldr x24, =0x0
	mov x12, v12.d[0]
	cmp x24, x12
	b.ne comparison_fail
	ldr x24, =0x0
	mov x12, v12.d[1]
	cmp x24, x12
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
	ldr x0, =0x0000100c
	ldr x1, =check_data1
	ldr x2, =0x00001014
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011fc
	ldr x1, =check_data2
	ldr x2, =0x00001200
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000013d0
	ldr x1, =check_data3
	ldr x2, =0x000013e0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001d7c
	ldr x1, =check_data4
	ldr x2, =0x00001d7e
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ff6
	ldr x1, =check_data5
	ldr x2, =0x00001ff8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x00400024
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00408004
	ldr x1, =check_data7
	ldr x2, =0x0040800c
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
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr ddc_el3, c24
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
