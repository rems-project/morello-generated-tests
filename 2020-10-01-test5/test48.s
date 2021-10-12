.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
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
	.byte 0x7f, 0xd1, 0x88, 0xd0, 0xd5, 0xde, 0x06, 0x78, 0xc3, 0x39, 0x02, 0x72, 0xfe, 0xc3, 0xc1, 0xc2
	.byte 0x47, 0x17, 0x12, 0xf8, 0x9e, 0x79, 0x5e, 0x82, 0x3e, 0xbb, 0x83, 0xe2, 0x7a, 0xd1, 0xc0, 0xc2
	.byte 0xa2, 0x7e, 0xe9, 0xc2, 0xaf, 0x11, 0xc5, 0xc2, 0xe0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4002000400ffffffffffe000
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0xc78000000000140
	/* C12 */
	.octa 0x40000000000300070000000000001004
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C21 */
	.octa 0x80000000000180063880000000000000
	/* C22 */
	.octa 0xf93
	/* C25 */
	.octa 0x80000000000180050000000000000fd9
	/* C26 */
	.octa 0x1000
final_cap_values:
	/* C1 */
	.octa 0x4002000400ffffffffffe000
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0xc78000000000140
	/* C12 */
	.octa 0x40000000000300070000000000001004
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C21 */
	.octa 0x80000000000180063880000000000000
	/* C22 */
	.octa 0x1000
	/* C25 */
	.octa 0x80000000000180050000000000000fd9
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0x4
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004200c2020000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000000000000000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001400
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword final_cap_values + 80
	.dword final_cap_values + 144
	.dword final_cap_values + 176
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd088d17f // ADRP-C.IP-C Rd:31 immhi:000100011010001011 P:1 10000:10000 immlo:10 op:1
	.inst 0x7806ded5 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:21 Rn:22 11:11 imm9:001101101 0:0 opc:00 111000:111000 size:01
	.inst 0x720239c3 // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:3 Rn:14 imms:001110 immr:000010 N:0 100100:100100 opc:11 sf:0
	.inst 0xc2c1c3fe // CVT-R.CC-C Rd:30 Cn:31 110000:110000 Cm:1 11000010110:11000010110
	.inst 0xf8121747 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:7 Rn:26 01:01 imm9:100100001 0:0 opc:00 111000:111000 size:11
	.inst 0x825e799e // ASTR-R.RI-32 Rt:30 Rn:12 op:10 imm9:111100111 L:0 1000001001:1000001001
	.inst 0xe283bb3e // ALDURSW-R.RI-64 Rt:30 Rn:25 op2:10 imm9:000111011 V:0 op1:10 11100010:11100010
	.inst 0xc2c0d17a // GCPERM-R.C-C Rd:26 Cn:11 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0xc2e97ea2 // ALDR-C.RRB-C Ct:2 Rn:21 1:1 L:1 S:1 option:011 Rm:9 11000010111:11000010111
	.inst 0xc2c511af // CVTD-R.C-C Rd:15 Cn:13 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0xc2c212e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x6, cptr_el3
	orr x6, x6, #0x200
	msr cptr_el3, x6
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c1 // ldr c1, [x6, #0]
	.inst 0xc24004c7 // ldr c7, [x6, #1]
	.inst 0xc24008c9 // ldr c9, [x6, #2]
	.inst 0xc2400ccc // ldr c12, [x6, #3]
	.inst 0xc24010cd // ldr c13, [x6, #4]
	.inst 0xc24014ce // ldr c14, [x6, #5]
	.inst 0xc24018d5 // ldr c21, [x6, #6]
	.inst 0xc2401cd6 // ldr c22, [x6, #7]
	.inst 0xc24020d9 // ldr c25, [x6, #8]
	.inst 0xc24024da // ldr c26, [x6, #9]
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =initial_csp_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2c1d0df // cpy c31, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	ldr x6, =0xc
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032e6 // ldr c6, [c23, #3]
	.inst 0xc28b4126 // msr ddc_el3, c6
	isb
	.inst 0x826012e6 // ldr c6, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr ddc_el3, c6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x23, #0xf
	and x6, x6, x23
	cmp x6, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d7 // ldr c23, [x6, #0]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc24004d7 // ldr c23, [x6, #1]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc24008d7 // ldr c23, [x6, #2]
	.inst 0xc2d7a461 // chkeq c3, c23
	b.ne comparison_fail
	.inst 0xc2400cd7 // ldr c23, [x6, #3]
	.inst 0xc2d7a4e1 // chkeq c7, c23
	b.ne comparison_fail
	.inst 0xc24010d7 // ldr c23, [x6, #4]
	.inst 0xc2d7a521 // chkeq c9, c23
	b.ne comparison_fail
	.inst 0xc24014d7 // ldr c23, [x6, #5]
	.inst 0xc2d7a581 // chkeq c12, c23
	b.ne comparison_fail
	.inst 0xc24018d7 // ldr c23, [x6, #6]
	.inst 0xc2d7a5a1 // chkeq c13, c23
	b.ne comparison_fail
	.inst 0xc2401cd7 // ldr c23, [x6, #7]
	.inst 0xc2d7a5c1 // chkeq c14, c23
	b.ne comparison_fail
	.inst 0xc24020d7 // ldr c23, [x6, #8]
	.inst 0xc2d7a5e1 // chkeq c15, c23
	b.ne comparison_fail
	.inst 0xc24024d7 // ldr c23, [x6, #9]
	.inst 0xc2d7a6a1 // chkeq c21, c23
	b.ne comparison_fail
	.inst 0xc24028d7 // ldr c23, [x6, #10]
	.inst 0xc2d7a6c1 // chkeq c22, c23
	b.ne comparison_fail
	.inst 0xc2402cd7 // ldr c23, [x6, #11]
	.inst 0xc2d7a721 // chkeq c25, c23
	b.ne comparison_fail
	.inst 0xc24030d7 // ldr c23, [x6, #12]
	.inst 0xc2d7a7c1 // chkeq c30, c23
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
	ldr x0, =0x00001014
	ldr x1, =check_data1
	ldr x2, =0x00001018
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001410
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017a0
	ldr x1, =check_data3
	ldr x2, =0x000017a4
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr ddc_el3, c6
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
