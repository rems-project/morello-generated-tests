.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0xc2, 0xa3, 0x99, 0xb8, 0x42, 0xe3, 0x3c, 0xab, 0x1f, 0xc4, 0x13, 0xb8, 0x22, 0xd7, 0x8a, 0x3c
	.byte 0xe2, 0x33, 0x6a, 0x82, 0x24, 0x50, 0xec, 0x69, 0x7e, 0x58, 0xcb, 0xc2, 0x8f, 0x15, 0x8c, 0xda
	.byte 0x21, 0xa0, 0xd9, 0xc2, 0xaa, 0xca, 0x9d, 0xb9, 0x00, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x2004
	/* C3 */
	.octa 0x800000070000000000000000
	/* C21 */
	.octa 0x0
	/* C25 */
	.octa 0x1a00
	/* C26 */
	.octa 0xffffffffffffffff
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x1402
final_cap_values:
	/* C0 */
	.octa 0xf3c
	/* C1 */
	.octa 0x1f64
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x800000070000000000000000
	/* C4 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C25 */
	.octa 0x1aad
	/* C26 */
	.octa 0xffffffffffffffff
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x800000070000000000000000
initial_csp_value:
	.octa 0x90000000400220020000000000401ae0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000002700040000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000400200c0000000000000c001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb899a3c2 // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:30 00:00 imm9:110011010 0:0 opc:10 111000:111000 size:10
	.inst 0xab3ce342 // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:2 Rn:26 imm3:000 option:111 Rm:28 01011001:01011001 S:1 op:0 sf:1
	.inst 0xb813c41f // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:0 01:01 imm9:100111100 0:0 opc:00 111000:111000 size:10
	.inst 0x3c8ad722 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:2 Rn:25 01:01 imm9:010101101 0:0 opc:10 111100:111100 size:00
	.inst 0x826a33e2 // ALDR-C.RI-C Ct:2 Rn:31 op:00 imm9:010100011 L:1 1000001001:1000001001
	.inst 0x69ec5024 // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:4 Rn:1 Rt2:10100 imm7:1011000 L:1 1010011:1010011 opc:01
	.inst 0xc2cb587e // ALIGNU-C.CI-C Cd:30 Cn:3 0110:0110 U:1 imm6:010110 11000010110:11000010110
	.inst 0xda8c158f // csneg:aarch64/instrs/integer/conditional/select Rd:15 Rn:12 o2:1 0:0 cond:0001 Rm:12 011010100:011010100 op:1 sf:1
	.inst 0xc2d9a021 // CLRPERM-C.CR-C Cd:1 Cn:1 000:000 1:1 10:10 Rm:25 11000010110:11000010110
	.inst 0xb99dcaaa // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:10 Rn:21 imm12:011101110010 opc:10 111001:111001 size:10
	.inst 0xc2c21200
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x7, cptr_el3
	orr x7, x7, #0x200
	msr cptr_el3, x7
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e1 // ldr c1, [x7, #1]
	.inst 0xc24008e3 // ldr c3, [x7, #2]
	.inst 0xc2400cf5 // ldr c21, [x7, #3]
	.inst 0xc24010f9 // ldr c25, [x7, #4]
	.inst 0xc24014fa // ldr c26, [x7, #5]
	.inst 0xc24018fc // ldr c28, [x7, #6]
	.inst 0xc2401cfe // ldr c30, [x7, #7]
	/* Vector registers */
	mrs x7, cptr_el3
	bfc x7, #10, #1
	msr cptr_el3, x7
	isb
	ldr q2, =0x0
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =initial_csp_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2c1d0ff // cpy c31, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x3085003a
	msr SCTLR_EL3, x7
	ldr x7, =0x0
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82603207 // ldr c7, [c16, #3]
	.inst 0xc28b4127 // msr ddc_el3, c7
	isb
	.inst 0x82601207 // ldr c7, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr ddc_el3, c7
	isb
	/* Check processor flags */
	mrs x7, nzcv
	ubfx x7, x7, #28, #4
	mov x16, #0xf
	and x7, x7, x16
	cmp x7, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000f0 // ldr c16, [x7, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc24004f0 // ldr c16, [x7, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc24008f0 // ldr c16, [x7, #2]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400cf0 // ldr c16, [x7, #3]
	.inst 0xc2d0a461 // chkeq c3, c16
	b.ne comparison_fail
	.inst 0xc24010f0 // ldr c16, [x7, #4]
	.inst 0xc2d0a481 // chkeq c4, c16
	b.ne comparison_fail
	.inst 0xc24014f0 // ldr c16, [x7, #5]
	.inst 0xc2d0a541 // chkeq c10, c16
	b.ne comparison_fail
	.inst 0xc24018f0 // ldr c16, [x7, #6]
	.inst 0xc2d0a681 // chkeq c20, c16
	b.ne comparison_fail
	.inst 0xc2401cf0 // ldr c16, [x7, #7]
	.inst 0xc2d0a6a1 // chkeq c21, c16
	b.ne comparison_fail
	.inst 0xc24020f0 // ldr c16, [x7, #8]
	.inst 0xc2d0a721 // chkeq c25, c16
	b.ne comparison_fail
	.inst 0xc24024f0 // ldr c16, [x7, #9]
	.inst 0xc2d0a741 // chkeq c26, c16
	b.ne comparison_fail
	.inst 0xc24028f0 // ldr c16, [x7, #10]
	.inst 0xc2d0a781 // chkeq c28, c16
	b.ne comparison_fail
	.inst 0xc2402cf0 // ldr c16, [x7, #11]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x7, =0x0
	mov x16, v2.d[0]
	cmp x7, x16
	b.ne comparison_fail
	ldr x7, =0x0
	mov x16, v2.d[1]
	cmp x7, x16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000139c
	ldr x1, =check_data1
	ldr x2, =0x000013a0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001a00
	ldr x1, =check_data2
	ldr x2, =0x00001a10
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001dc8
	ldr x1, =check_data3
	ldr x2, =0x00001dcc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f64
	ldr x1, =check_data4
	ldr x2, =0x00001f6c
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
	ldr x0, =0x00402510
	ldr x1, =check_data6
	ldr x2, =0x00402520
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr ddc_el3, c7
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
