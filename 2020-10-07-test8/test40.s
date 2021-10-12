.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x88, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x80
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0xc0
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 8
.data
check_data6:
	.byte 0x40, 0x86, 0x19, 0xa2, 0x90, 0x50, 0x96, 0x37, 0x41, 0x03, 0x1f, 0xfa, 0x61, 0x01, 0x2d, 0x39
	.byte 0x34, 0x4c, 0x5e, 0x82, 0x1f, 0xe4, 0xd2, 0x68, 0xc6, 0x7a, 0x59, 0x38, 0x1e, 0x08, 0xa3, 0x9b
	.byte 0x54, 0xff, 0x56, 0x78, 0x7e, 0x1a, 0xa3, 0xb9, 0x80, 0x13, 0xc2, 0xc2
.data
check_data7:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80004000000000000000000000001188
	/* C11 */
	.octa 0x40000000080180060000000000000800
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x48000000000100070000000000001000
	/* C19 */
	.octa 0x800000007ffc3fd80000000000401cc0
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x80000000000100070000000000001476
	/* C26 */
	.octa 0x800000000047003f00000000000010c1
final_cap_values:
	/* C0 */
	.octa 0x8000400000000000000000000000121c
	/* C1 */
	.octa 0x10c0
	/* C6 */
	.octa 0x0
	/* C11 */
	.octa 0x40000000080180060000000000000800
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x48000000000100070000000000000980
	/* C19 */
	.octa 0x800000007ffc3fd80000000000401cc0
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x80000000000100070000000000001476
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x800000000047003f0000000000001030
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000007fc40bea0000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2198640 // STR-C.RIAW-C Ct:0 Rn:18 01:01 imm9:110011000 0:0 opc:00 10100010:10100010
	.inst 0x37965090 // tbnz:aarch64/instrs/branch/conditional/test Rt:16 imm14:11001010000100 b40:10010 op:1 011011:011011 b5:0
	.inst 0xfa1f0341 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:26 000000:000000 Rm:31 11010000:11010000 S:1 op:1 sf:1
	.inst 0x392d0161 // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:11 imm12:101101000000 opc:00 111001:111001 size:00
	.inst 0x825e4c34 // ASTR-R.RI-64 Rt:20 Rn:1 op:11 imm9:111100100 L:0 1000001001:1000001001
	.inst 0x68d2e41f // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:31 Rn:0 Rt2:11001 imm7:0100101 L:1 1010001:1010001 opc:01
	.inst 0x38597ac6 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:6 Rn:22 10:10 imm9:110010111 0:0 opc:01 111000:111000 size:00
	.inst 0x9ba3081e // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:30 Rn:0 Ra:2 o0:0 Rm:3 01:01 U:1 10011011:10011011
	.inst 0x7856ff54 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:20 Rn:26 11:11 imm9:101101111 0:0 opc:01 111000:111000 size:01
	.inst 0xb9a31a7e // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:19 imm12:100011000110 opc:10 111001:111001 size:10
	.inst 0xc2c21380
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
	.inst 0xc24005ab // ldr c11, [x13, #1]
	.inst 0xc24009b0 // ldr c16, [x13, #2]
	.inst 0xc2400db2 // ldr c18, [x13, #3]
	.inst 0xc24011b3 // ldr c19, [x13, #4]
	.inst 0xc24015b4 // ldr c20, [x13, #5]
	.inst 0xc24019b6 // ldr c22, [x13, #6]
	.inst 0xc2401dba // ldr c26, [x13, #7]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	ldr x13, =0x0
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x8260338d // ldr c13, [c28, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x8260138d // ldr c13, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
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
	mov x28, #0xf
	and x13, x13, x28
	cmp x13, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001bc // ldr c28, [x13, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc24005bc // ldr c28, [x13, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc24009bc // ldr c28, [x13, #2]
	.inst 0xc2dca4c1 // chkeq c6, c28
	b.ne comparison_fail
	.inst 0xc2400dbc // ldr c28, [x13, #3]
	.inst 0xc2dca561 // chkeq c11, c28
	b.ne comparison_fail
	.inst 0xc24011bc // ldr c28, [x13, #4]
	.inst 0xc2dca601 // chkeq c16, c28
	b.ne comparison_fail
	.inst 0xc24015bc // ldr c28, [x13, #5]
	.inst 0xc2dca641 // chkeq c18, c28
	b.ne comparison_fail
	.inst 0xc24019bc // ldr c28, [x13, #6]
	.inst 0xc2dca661 // chkeq c19, c28
	b.ne comparison_fail
	.inst 0xc2401dbc // ldr c28, [x13, #7]
	.inst 0xc2dca681 // chkeq c20, c28
	b.ne comparison_fail
	.inst 0xc24021bc // ldr c28, [x13, #8]
	.inst 0xc2dca6c1 // chkeq c22, c28
	b.ne comparison_fail
	.inst 0xc24025bc // ldr c28, [x13, #9]
	.inst 0xc2dca721 // chkeq c25, c28
	b.ne comparison_fail
	.inst 0xc24029bc // ldr c28, [x13, #10]
	.inst 0xc2dca741 // chkeq c26, c28
	b.ne comparison_fail
	.inst 0xc2402dbc // ldr c28, [x13, #11]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001030
	ldr x1, =check_data1
	ldr x2, =0x00001032
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001188
	ldr x1, =check_data2
	ldr x2, =0x00001190
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001340
	ldr x1, =check_data3
	ldr x2, =0x00001341
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0000140d
	ldr x1, =check_data4
	ldr x2, =0x0000140e
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fe0
	ldr x1, =check_data5
	ldr x2, =0x00001fe8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00403fd8
	ldr x1, =check_data7
	ldr x2, =0x00403fdc
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
