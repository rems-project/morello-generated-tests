.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x3f, 0x64, 0xce, 0xc2, 0xc0, 0x13, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
check_data6:
	.byte 0x0f, 0xb8, 0x54, 0xfa, 0x5d, 0x80, 0x42, 0x38, 0xfe, 0x63, 0x9a, 0x5a, 0x05, 0x68, 0xd8, 0xc2
	.byte 0xe0, 0x23, 0x10, 0x78, 0xe0, 0xa7, 0x52, 0xe2, 0x5f, 0xfc, 0x9f, 0x48, 0x5e, 0x79, 0xd5, 0x18
	.byte 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000000000000000000000000
	/* C1 */
	.octa 0x45004c00200ffffffffffc000
	/* C2 */
	.octa 0x17e4
	/* C14 */
	.octa 0x1
	/* C30 */
	.octa 0xa0008000000010000000000000460000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x45004c00200ffffffffffc000
	/* C2 */
	.octa 0x17e4
	/* C14 */
	.octa 0x1
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0x80000000100700080000000000001200
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001006000f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005c0100000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2ce643f // CPYVALUE-C.C-C Cd:31 Cn:1 001:001 opc:11 0:0 Cm:14 11000010110:11000010110
	.inst 0xc2c213c0 // BR-C-C 00000:00000 Cn:30 100:100 opc:00 11000010110000100:11000010110000100
	.zero 393208
	.inst 0xfa54b80f // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1111 0:0 Rn:0 10:10 cond:1011 imm5:10100 111010010:111010010 op:1 sf:1
	.inst 0x3842805d // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:29 Rn:2 00:00 imm9:000101000 0:0 opc:01 111000:111000 size:00
	.inst 0x5a9a63fe // csinv:aarch64/instrs/integer/conditional/select Rd:30 Rn:31 o2:0 0:0 cond:0110 Rm:26 011010100:011010100 op:1 sf:0
	.inst 0xc2d86805 // ORRFLGS-C.CR-C Cd:5 Cn:0 1010:1010 opc:01 Rm:24 11000010110:11000010110
	.inst 0x781023e0 // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:31 00:00 imm9:100000010 0:0 opc:00 111000:111000 size:01
	.inst 0xe252a7e0 // ALDURH-R.RI-32 Rt:0 Rn:31 op2:01 imm9:100101010 V:0 op1:01 11100010:11100010
	.inst 0x489ffc5f // stlrh:aarch64/instrs/memory/ordered Rt:31 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x18d5795e // ldr_lit_gen:aarch64/instrs/memory/literal/general Rt:30 imm19:1101010101111001010 011000:011000 opc:00
	.inst 0xc2c21120
	.zero 655324
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x18, cptr_el3
	orr x18, x18, #0x200
	msr cptr_el3, x18
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400641 // ldr c1, [x18, #1]
	.inst 0xc2400a42 // ldr c2, [x18, #2]
	.inst 0xc2400e4e // ldr c14, [x18, #3]
	.inst 0xc240125e // ldr c30, [x18, #4]
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =initial_csp_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2c1d25f // cpy c31, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30850038
	msr SCTLR_EL3, x18
	ldr x18, =0x4
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603132 // ldr c18, [c9, #3]
	.inst 0xc28b4132 // msr ddc_el3, c18
	isb
	.inst 0x82601132 // ldr c18, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr ddc_el3, c18
	isb
	/* Check processor flags */
	mrs x18, nzcv
	ubfx x18, x18, #28, #4
	mov x9, #0xf
	and x18, x18, x9
	cmp x18, #0xf
	b.ne comparison_fail
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400249 // ldr c9, [x18, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400649 // ldr c9, [x18, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400a49 // ldr c9, [x18, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400e49 // ldr c9, [x18, #3]
	.inst 0xc2c9a5c1 // chkeq c14, c9
	b.ne comparison_fail
	.inst 0xc2401249 // ldr c9, [x18, #4]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc2401649 // ldr c9, [x18, #5]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001102
	ldr x1, =check_data0
	ldr x2, =0x00001104
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000112a
	ldr x1, =check_data1
	ldr x2, =0x0000112c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017e4
	ldr x1, =check_data2
	ldr x2, =0x000017e6
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000180c
	ldr x1, =check_data3
	ldr x2, =0x0000180d
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400008
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0040af44
	ldr x1, =check_data5
	ldr x2, =0x0040af48
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00460000
	ldr x1, =check_data6
	ldr x2, =0x00460024
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
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr ddc_el3, c18
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
