.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x80, 0x2f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xfe, 0x0f, 0xc2, 0x1a, 0xf5, 0x23, 0x15, 0x3c, 0xed, 0xe8, 0xa0, 0x82, 0x5f, 0x37, 0x4c, 0xb8
	.byte 0xb8, 0x7d, 0xdf, 0xc8, 0x40, 0x00, 0x56, 0x82, 0xcd, 0x0a, 0xc0, 0x5a, 0xd1, 0x2b, 0xde, 0xc2
	.byte 0xd2, 0x53, 0x25, 0x9b, 0x6f, 0x13, 0xc0, 0xc2, 0xe0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2f80
	/* C2 */
	.octa 0x40000000600000010000000000000000
	/* C7 */
	.octa 0x4000000000070807ffffffffffffe080
	/* C13 */
	.octa 0x1000
	/* C26 */
	.octa 0x1000
	/* C27 */
	.octa 0x400000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x2f80
	/* C2 */
	.octa 0x40000000600000010000000000000000
	/* C7 */
	.octa 0x4000000000070807ffffffffffffe080
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x10c3
	/* C27 */
	.octa 0x400000000000000000000000
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0x2010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000010700050000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x1ac20ffe // sdiv:aarch64/instrs/integer/arithmetic/div Rd:30 Rn:31 o1:1 00001:00001 Rm:2 0011010110:0011010110 sf:0
	.inst 0x3c1523f5 // stur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:21 Rn:31 00:00 imm9:101010010 0:0 opc:00 111100:111100 size:00
	.inst 0x82a0e8ed // ASTR-V.RRB-D Rt:13 Rn:7 opc:10 S:0 option:111 Rm:0 1:1 L:0 100000101:100000101
	.inst 0xb84c375f // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:26 01:01 imm9:011000011 0:0 opc:01 111000:111000 size:10
	.inst 0xc8df7db8 // ldlar:aarch64/instrs/memory/ordered Rt:24 Rn:13 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0x82560040 // ASTR-C.RI-C Ct:0 Rn:2 op:00 imm9:101100000 L:0 1000001001:1000001001
	.inst 0x5ac00acd // rev:aarch64/instrs/integer/arithmetic/rev Rd:13 Rn:22 opc:10 1011010110000000000:1011010110000000000 sf:0
	.inst 0xc2de2bd1 // BICFLGS-C.CR-C Cd:17 Cn:30 1010:1010 opc:00 Rm:30 11000010110:11000010110
	.inst 0x9b2553d2 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:18 Rn:30 Ra:20 o0:0 Rm:5 01:01 U:0 10011011:10011011
	.inst 0xc2c0136f // GCBASE-R.C-C Rd:15 Cn:27 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0xc2c212e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x25, cptr_el3
	orr x25, x25, #0x200
	msr cptr_el3, x25
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
	ldr x25, =initial_cap_values
	.inst 0xc2400320 // ldr c0, [x25, #0]
	.inst 0xc2400722 // ldr c2, [x25, #1]
	.inst 0xc2400b27 // ldr c7, [x25, #2]
	.inst 0xc2400f2d // ldr c13, [x25, #3]
	.inst 0xc240133a // ldr c26, [x25, #4]
	.inst 0xc240173b // ldr c27, [x25, #5]
	/* Vector registers */
	mrs x25, cptr_el3
	bfc x25, #10, #1
	msr cptr_el3, x25
	isb
	ldr q13, =0x0
	ldr q21, =0x0
	/* Set up flags and system registers */
	mov x25, #0x00000000
	msr nzcv, x25
	ldr x25, =initial_csp_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2c1d33f // cpy c31, c25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30850032
	msr SCTLR_EL3, x25
	ldr x25, =0x4
	msr S3_6_C1_C2_2, x25 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032f9 // ldr c25, [c23, #3]
	.inst 0xc28b4139 // msr ddc_el3, c25
	isb
	.inst 0x826012f9 // ldr c25, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c21320 // br c25
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr ddc_el3, c25
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400337 // ldr c23, [x25, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400737 // ldr c23, [x25, #1]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400b37 // ldr c23, [x25, #2]
	.inst 0xc2d7a4e1 // chkeq c7, c23
	b.ne comparison_fail
	.inst 0xc2400f37 // ldr c23, [x25, #3]
	.inst 0xc2d7a5e1 // chkeq c15, c23
	b.ne comparison_fail
	.inst 0xc2401337 // ldr c23, [x25, #4]
	.inst 0xc2d7a621 // chkeq c17, c23
	b.ne comparison_fail
	.inst 0xc2401737 // ldr c23, [x25, #5]
	.inst 0xc2d7a701 // chkeq c24, c23
	b.ne comparison_fail
	.inst 0xc2401b37 // ldr c23, [x25, #6]
	.inst 0xc2d7a741 // chkeq c26, c23
	b.ne comparison_fail
	.inst 0xc2401f37 // ldr c23, [x25, #7]
	.inst 0xc2d7a761 // chkeq c27, c23
	b.ne comparison_fail
	.inst 0xc2402337 // ldr c23, [x25, #8]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x25, =0x0
	mov x23, v13.d[0]
	cmp x25, x23
	b.ne comparison_fail
	ldr x25, =0x0
	mov x23, v13.d[1]
	cmp x25, x23
	b.ne comparison_fail
	ldr x25, =0x0
	mov x23, v21.d[0]
	cmp x25, x23
	b.ne comparison_fail
	ldr x25, =0x0
	mov x23, v21.d[1]
	cmp x25, x23
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
	ldr x0, =0x00001600
	ldr x1, =check_data1
	ldr x2, =0x00001610
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f62
	ldr x1, =check_data2
	ldr x2, =0x00001f63
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr ddc_el3, c25
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
