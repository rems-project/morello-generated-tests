.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x35, 0xa4, 0x64, 0x6d, 0xc2, 0x73, 0xc0, 0xc2, 0xc2, 0x33, 0xc2, 0xc2
.data
check_data1:
	.byte 0x2b, 0x53, 0xc1, 0xc2, 0x43, 0x94, 0x1a, 0xe2, 0x37, 0x18, 0x09, 0xe2, 0xff, 0x67, 0x38, 0xd0
	.byte 0xb6, 0x61, 0x28, 0x9b, 0xeb, 0x1b, 0x42, 0x3a, 0xe0, 0x10, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2
.data
check_data4:
	.byte 0xa0, 0x86, 0xd9, 0xc2
.data
check_data5:
	.byte 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x2001b8
	/* C21 */
	.octa 0x20408010000100050000000000400081
	/* C25 */
	.octa 0x400010000000000000000000000000
	/* C30 */
	.octa 0x200080002007400000000000004e0001
final_cap_values:
	/* C1 */
	.octa 0x2001b8
	/* C2 */
	.octa 0x2e0001
	/* C3 */
	.octa 0xc2
	/* C11 */
	.octa 0x40001000000000
	/* C21 */
	.octa 0x20408010000100050000000000400081
	/* C23 */
	.octa 0xffffffffffffffc2
	/* C25 */
	.octa 0x400010000000000000000000000000
	/* C29 */
	.octa 0x400000000000000000000000000000
	/* C30 */
	.octa 0x2000800000008008000000000040000c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x8000000004060223000000000004c000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x6d64a435 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:21 Rn:1 Rt2:01001 imm7:1001001 L:1 1011010:1011010 opc:01
	.inst 0xc2c073c2 // GCOFF-R.C-C Rd:2 Cn:30 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0xc2c233c2 // BLRS-C-C 00010:00010 Cn:30 100:100 opc:01 11000010110000100:11000010110000100
	.zero 116
	.inst 0xc2c1532b // CFHI-R.C-C Rd:11 Cn:25 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xe21a9443 // ALDURB-R.RI-32 Rt:3 Rn:2 op2:01 imm9:110101001 V:0 op1:00 11100010:11100010
	.inst 0xe2091837 // ALDURSB-R.RI-64 Rt:23 Rn:1 op2:10 imm9:010010001 V:0 op1:00 11100010:11100010
	.inst 0xd03867ff // ADRDP-C.ID-C Rd:31 immhi:011100001100111111 P:0 10000:10000 immlo:10 op:1
	.inst 0x9b2861b6 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:22 Rn:13 Ra:24 o0:0 Rm:8 01:01 U:0 10011011:10011011
	.inst 0x3a421beb // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1011 0:0 Rn:31 10:10 cond:0001 imm5:00010 111010010:111010010 op:0 sf:0
	.inst 0xc2c210e0
	.zero 130916
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 568
	.inst 0x0000c200
	.zero 785844
	.inst 0xc2d986a0 // BRS-C.C-C 00000:00000 Cn:21 001:001 opc:00 1:1 Cm:25 11000010110:11000010110
	.zero 130980
	.inst 0x00c20000
	.zero 84
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x4, cptr_el3
	orr x4, x4, #0x200
	msr cptr_el3, x4
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
	ldr x4, =initial_cap_values
	.inst 0xc2400081 // ldr c1, [x4, #0]
	.inst 0xc2400495 // ldr c21, [x4, #1]
	.inst 0xc2400899 // ldr c25, [x4, #2]
	.inst 0xc2400c9e // ldr c30, [x4, #3]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30850032
	msr SCTLR_EL3, x4
	ldr x4, =0x4
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030e4 // ldr c4, [c7, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x826010e4 // ldr c4, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	/* Check processor flags */
	mrs x4, nzcv
	ubfx x4, x4, #28, #4
	mov x7, #0xf
	and x4, x4, x7
	cmp x4, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400087 // ldr c7, [x4, #0]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400487 // ldr c7, [x4, #1]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400887 // ldr c7, [x4, #2]
	.inst 0xc2c7a461 // chkeq c3, c7
	b.ne comparison_fail
	.inst 0xc2400c87 // ldr c7, [x4, #3]
	.inst 0xc2c7a561 // chkeq c11, c7
	b.ne comparison_fail
	.inst 0xc2401087 // ldr c7, [x4, #4]
	.inst 0xc2c7a6a1 // chkeq c21, c7
	b.ne comparison_fail
	.inst 0xc2401487 // ldr c7, [x4, #5]
	.inst 0xc2c7a6e1 // chkeq c23, c7
	b.ne comparison_fail
	.inst 0xc2401887 // ldr c7, [x4, #6]
	.inst 0xc2c7a721 // chkeq c25, c7
	b.ne comparison_fail
	.inst 0xc2401c87 // ldr c7, [x4, #7]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2402087 // ldr c7, [x4, #8]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check vector registers */
	ldr x4, =0xc2c2c2c2c2c2c2c2
	mov x7, v9.d[0]
	cmp x4, x7
	b.ne comparison_fail
	ldr x4, =0x0
	mov x7, v9.d[1]
	cmp x4, x7
	b.ne comparison_fail
	ldr x4, =0xc2c2c2c2c2c2c2c2
	mov x7, v21.d[0]
	cmp x4, x7
	b.ne comparison_fail
	ldr x4, =0x0
	mov x7, v21.d[1]
	cmp x4, x7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00400000
	ldr x1, =check_data0
	ldr x2, =0x0040000c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400080
	ldr x1, =check_data1
	ldr x2, =0x0040009c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00420000
	ldr x1, =check_data2
	ldr x2, =0x00420010
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00420249
	ldr x1, =check_data3
	ldr x2, =0x0042024a
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004e0000
	ldr x1, =check_data4
	ldr x2, =0x004e0004
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004fffaa
	ldr x1, =check_data5
	ldr x2, =0x004fffab
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
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
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
