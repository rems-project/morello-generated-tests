.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x01, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xf8, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x19, 0xc0, 0x43, 0x38, 0xc0, 0xbb, 0x2e, 0xa8, 0x1c, 0xf3, 0xc5, 0xc2, 0x27, 0xe8, 0xe7, 0x78
	.byte 0x3e, 0xd0, 0x0b, 0xfc, 0x6e, 0x7d, 0x7f, 0x42, 0xdf, 0x8a, 0x03, 0xe2, 0x49, 0xbf, 0xbf, 0x9b
	.byte 0x89, 0xa1, 0xb7, 0x50, 0x01, 0x84, 0xcc, 0xc2, 0x80, 0x10, 0xc2, 0xc2
.data
check_data6:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x500000020000000000000ff8
	/* C1 */
	.octa 0xf3a
	/* C7 */
	.octa 0x1001
	/* C11 */
	.octa 0x80000000400280000000000000408000
	/* C12 */
	.octa 0x100030000000000000000
	/* C14 */
	.octa 0x0
	/* C22 */
	.octa 0x80000000200300070000000000001002
	/* C24 */
	.octa 0x400001
	/* C30 */
	.octa 0x11f7
final_cap_values:
	/* C0 */
	.octa 0x500000020000000000000ff8
	/* C1 */
	.octa 0xf3a
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x36f452
	/* C11 */
	.octa 0x80000000400280000000000000408000
	/* C12 */
	.octa 0x100030000000000000000
	/* C14 */
	.octa 0x0
	/* C22 */
	.octa 0x80000000200300070000000000001002
	/* C24 */
	.octa 0x400001
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0x20008000480000000000000000400001
	/* C30 */
	.octa 0x11f7
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000480000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000004002000900fffffffffff801
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3843c019 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:25 Rn:0 00:00 imm9:000111100 0:0 opc:01 111000:111000 size:00
	.inst 0xa82ebbc0 // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:0 Rn:30 Rt2:01110 imm7:1011101 L:0 1010000:1010000 opc:10
	.inst 0xc2c5f31c // CVTPZ-C.R-C Cd:28 Rn:24 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0x78e7e827 // ldrsh_reg:aarch64/instrs/memory/single/general/register Rt:7 Rn:1 10:10 S:0 option:111 Rm:7 1:1 opc:11 111000:111000 size:01
	.inst 0xfc0bd03e // stur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:30 Rn:1 00:00 imm9:010111101 0:0 opc:00 111100:111100 size:11
	.inst 0x427f7d6e // ALDARB-R.R-B Rt:14 Rn:11 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xe2038adf // ALDURSB-R.RI-64 Rt:31 Rn:22 op2:10 imm9:000111000 V:0 op1:00 11100010:11100010
	.inst 0x9bbfbf49 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:9 Rn:26 Ra:15 o0:1 Rm:31 01:01 U:1 10011011:10011011
	.inst 0x50b7a189 // ADR-C.I-C Rd:9 immhi:011011110100001100 P:1 10000:10000 immlo:10 op:0
	.inst 0xc2cc8401 // CHKSS-_.CC-C 00001:00001 Cn:0 001:001 opc:00 1:1 Cm:12 11000010110:11000010110
	.inst 0xc2c21080
	.zero 1048532
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
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400661 // ldr c1, [x19, #1]
	.inst 0xc2400a67 // ldr c7, [x19, #2]
	.inst 0xc2400e6b // ldr c11, [x19, #3]
	.inst 0xc240126c // ldr c12, [x19, #4]
	.inst 0xc240166e // ldr c14, [x19, #5]
	.inst 0xc2401a76 // ldr c22, [x19, #6]
	.inst 0xc2401e78 // ldr c24, [x19, #7]
	.inst 0xc240227e // ldr c30, [x19, #8]
	/* Vector registers */
	mrs x19, cptr_el3
	bfc x19, #10, #1
	msr cptr_el3, x19
	isb
	ldr q30, =0x400000000100
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	ldr x19, =0x4
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603093 // ldr c19, [c4, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x82601093 // ldr c19, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
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
	mov x4, #0xf
	and x19, x19, x4
	cmp x19, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400264 // ldr c4, [x19, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400664 // ldr c4, [x19, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400a64 // ldr c4, [x19, #2]
	.inst 0xc2c4a4e1 // chkeq c7, c4
	b.ne comparison_fail
	.inst 0xc2400e64 // ldr c4, [x19, #3]
	.inst 0xc2c4a521 // chkeq c9, c4
	b.ne comparison_fail
	.inst 0xc2401264 // ldr c4, [x19, #4]
	.inst 0xc2c4a561 // chkeq c11, c4
	b.ne comparison_fail
	.inst 0xc2401664 // ldr c4, [x19, #5]
	.inst 0xc2c4a581 // chkeq c12, c4
	b.ne comparison_fail
	.inst 0xc2401a64 // ldr c4, [x19, #6]
	.inst 0xc2c4a5c1 // chkeq c14, c4
	b.ne comparison_fail
	.inst 0xc2401e64 // ldr c4, [x19, #7]
	.inst 0xc2c4a6c1 // chkeq c22, c4
	b.ne comparison_fail
	.inst 0xc2402264 // ldr c4, [x19, #8]
	.inst 0xc2c4a701 // chkeq c24, c4
	b.ne comparison_fail
	.inst 0xc2402664 // ldr c4, [x19, #9]
	.inst 0xc2c4a721 // chkeq c25, c4
	b.ne comparison_fail
	.inst 0xc2402a64 // ldr c4, [x19, #10]
	.inst 0xc2c4a781 // chkeq c28, c4
	b.ne comparison_fail
	.inst 0xc2402e64 // ldr c4, [x19, #11]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x400000000100
	mov x4, v30.d[0]
	cmp x19, x4
	b.ne comparison_fail
	ldr x19, =0x0
	mov x4, v30.d[1]
	cmp x19, x4
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
	ldr x0, =0x0000103a
	ldr x1, =check_data1
	ldr x2, =0x0000103b
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000103d
	ldr x1, =check_data2
	ldr x2, =0x0000103e
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010e8
	ldr x1, =check_data3
	ldr x2, =0x000010f8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f44
	ldr x1, =check_data4
	ldr x2, =0x00001f46
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
	ldr x0, =0x00408000
	ldr x1, =check_data6
	ldr x2, =0x00408001
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
