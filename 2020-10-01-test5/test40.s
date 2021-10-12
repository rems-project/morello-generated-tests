.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0xa1, 0xa3, 0xf9, 0xc2, 0xd1, 0x48, 0x0b, 0xe2, 0x01, 0x98, 0xfe, 0xc2, 0x5b, 0x58, 0xe0, 0xc2
	.byte 0x6d, 0x44, 0x4c, 0x38, 0xa3, 0x11, 0xc0, 0x5a, 0x0c, 0xe2, 0x19, 0x6c, 0x1e, 0x07, 0x80, 0xf9
	.byte 0x7f, 0x6a, 0x1c, 0x78, 0x01, 0x40, 0x82, 0x1a, 0x80, 0x11, 0xc2, 0xc2
.data
check_data3:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x3fff800000000000000000000000
	/* C3 */
	.octa 0x80000000004700170000000000001000
	/* C6 */
	.octa 0x4f8008
	/* C16 */
	.octa 0x40000000000710070000000000000e88
	/* C19 */
	.octa 0x4000000002030007000000000000103a
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x3fff800000000000000000000000
	/* C3 */
	.octa 0x20
	/* C6 */
	.octa 0x4f8008
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0x40000000000710070000000000000e88
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x4000000002030007000000000000103a
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000008e20070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000200100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2f9a3a1 // BICFLGS-C.CI-C Cd:1 Cn:29 0:0 00:00 imm8:11001101 11000010111:11000010111
	.inst 0xe20b48d1 // ALDURSB-R.RI-64 Rt:17 Rn:6 op2:10 imm9:010110100 V:0 op1:00 11100010:11100010
	.inst 0xc2fe9801 // SUBS-R.CC-C Rd:1 Cn:0 100110:100110 Cm:30 11000010111:11000010111
	.inst 0xc2e0585b // CVTZ-C.CR-C Cd:27 Cn:2 0110:0110 1:1 0:0 Rm:0 11000010111:11000010111
	.inst 0x384c446d // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:13 Rn:3 01:01 imm9:011000100 0:0 opc:01 111000:111000 size:00
	.inst 0x5ac011a3 // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:3 Rn:13 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0x6c19e20c // stnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:12 Rn:16 Rt2:11000 imm7:0110011 L:0 1011000:1011000 opc:01
	.inst 0xf980071e // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:24 imm12:000000000001 opc:10 111001:111001 size:11
	.inst 0x781c6a7f // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:19 10:10 imm9:111000110 0:0 opc:00 111000:111000 size:01
	.inst 0x1a824001 // csel:aarch64/instrs/integer/conditional/select Rd:1 Rn:0 o2:0 0:0 cond:0100 Rm:2 011010100:011010100 op:0 sf:0
	.inst 0xc2c21180
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x26, cptr_el3
	orr x26, x26, #0x200
	msr cptr_el3, x26
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
	ldr x26, =initial_cap_values
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400742 // ldr c2, [x26, #1]
	.inst 0xc2400b43 // ldr c3, [x26, #2]
	.inst 0xc2400f46 // ldr c6, [x26, #3]
	.inst 0xc2401350 // ldr c16, [x26, #4]
	.inst 0xc2401753 // ldr c19, [x26, #5]
	.inst 0xc2401b5d // ldr c29, [x26, #6]
	.inst 0xc2401f5e // ldr c30, [x26, #7]
	/* Vector registers */
	mrs x26, cptr_el3
	bfc x26, #10, #1
	msr cptr_el3, x26
	isb
	ldr q12, =0x0
	ldr q24, =0x0
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30850032
	msr SCTLR_EL3, x26
	ldr x26, =0x0
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x8260319a // ldr c26, [c12, #3]
	.inst 0xc28b413a // msr ddc_el3, c26
	isb
	.inst 0x8260119a // ldr c26, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr ddc_el3, c26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x12, #0xf
	and x26, x26, x12
	cmp x26, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc240034c // ldr c12, [x26, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240074c // ldr c12, [x26, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc2400b4c // ldr c12, [x26, #2]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400f4c // ldr c12, [x26, #3]
	.inst 0xc2cca461 // chkeq c3, c12
	b.ne comparison_fail
	.inst 0xc240134c // ldr c12, [x26, #4]
	.inst 0xc2cca4c1 // chkeq c6, c12
	b.ne comparison_fail
	.inst 0xc240174c // ldr c12, [x26, #5]
	.inst 0xc2cca5a1 // chkeq c13, c12
	b.ne comparison_fail
	.inst 0xc2401b4c // ldr c12, [x26, #6]
	.inst 0xc2cca601 // chkeq c16, c12
	b.ne comparison_fail
	.inst 0xc2401f4c // ldr c12, [x26, #7]
	.inst 0xc2cca621 // chkeq c17, c12
	b.ne comparison_fail
	.inst 0xc240234c // ldr c12, [x26, #8]
	.inst 0xc2cca661 // chkeq c19, c12
	b.ne comparison_fail
	.inst 0xc240274c // ldr c12, [x26, #9]
	.inst 0xc2cca761 // chkeq c27, c12
	b.ne comparison_fail
	.inst 0xc2402b4c // ldr c12, [x26, #10]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc2402f4c // ldr c12, [x26, #11]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x26, =0x0
	mov x12, v12.d[0]
	cmp x26, x12
	b.ne comparison_fail
	ldr x26, =0x0
	mov x12, v12.d[1]
	cmp x26, x12
	b.ne comparison_fail
	ldr x26, =0x0
	mov x12, v24.d[0]
	cmp x26, x12
	b.ne comparison_fail
	ldr x26, =0x0
	mov x12, v24.d[1]
	cmp x26, x12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001030
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004f80bc
	ldr x1, =check_data3
	ldr x2, =0x004f80bd
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
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr ddc_el3, c26
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
