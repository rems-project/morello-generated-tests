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
	.byte 0xe1, 0xe0, 0x62, 0xe2, 0xee, 0x21, 0xdf, 0x1a, 0x01, 0x20, 0x54, 0xe2, 0x5e, 0x28, 0xc2, 0x9a
	.byte 0x16, 0x28, 0x06, 0x78, 0xe0, 0x01, 0x5f, 0xd6
.data
check_data5:
	.byte 0xa5, 0xfb, 0xc8, 0xb5, 0x65, 0x13, 0x44, 0x38, 0x83, 0x33, 0xc2, 0xc2
.data
check_data6:
	.byte 0xc1, 0x8a, 0xb6, 0x70, 0x40, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4000000000008008000000000000120e
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x40000000400000190000000000000fec
	/* C15 */
	.octa 0x400078
	/* C22 */
	.octa 0x0
	/* C27 */
	.octa 0x17b5
	/* C28 */
	.octa 0x20000000840100070000000000440000
final_cap_values:
	/* C0 */
	.octa 0x4000000000008008000000000000120e
	/* C1 */
	.octa 0x3ad15b
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x40000000400000190000000000000fec
	/* C14 */
	.octa 0x400078
	/* C15 */
	.octa 0x400078
	/* C22 */
	.octa 0x0
	/* C27 */
	.octa 0x17b5
	/* C28 */
	.octa 0x20000000840100070000000000440000
	/* C30 */
	.octa 0x20008000000000000000000000400084
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000002706000f0000000000002021
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe262e0e1 // ASTUR-V.RI-H Rt:1 Rn:7 op2:00 imm9:000101110 V:1 op1:01 11100010:11100010
	.inst 0x1adf21ee // lslv:aarch64/instrs/integer/shift/variable Rd:14 Rn:15 op2:00 0010:0010 Rm:31 0011010110:0011010110 sf:0
	.inst 0xe2542001 // ASTURH-R.RI-32 Rt:1 Rn:0 op2:00 imm9:101000010 V:0 op1:01 11100010:11100010
	.inst 0x9ac2285e // asrv:aarch64/instrs/integer/shift/variable Rd:30 Rn:2 op2:10 0010:0010 Rm:2 0011010110:0011010110 sf:1
	.inst 0x78062816 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:22 Rn:0 10:10 imm9:001100010 0:0 opc:00 111000:111000 size:01
	.inst 0xd65f01e0 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:15 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 96
	.inst 0xb5c8fba5 // cbnz:aarch64/instrs/branch/conditional/compare Rt:5 imm19:1100100011111011101 op:1 011010:011010 sf:1
	.inst 0x38441365 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:5 Rn:27 00:00 imm9:001000001 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c23383 // BLRR-C-C 00011:00011 Cn:28 100:100 opc:01 11000010110000100:11000010110000100
	.zero 262012
	.inst 0x70b68ac1 // ADR-C.I-C Rd:1 immhi:011011010001010110 P:1 10000:10000 immlo:11 op:0
	.inst 0xc2c21240
	.zero 786424
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x12, cptr_el3
	orr x12, x12, #0x200
	msr cptr_el3, x12
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
	ldr x12, =initial_cap_values
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400581 // ldr c1, [x12, #1]
	.inst 0xc2400985 // ldr c5, [x12, #2]
	.inst 0xc2400d87 // ldr c7, [x12, #3]
	.inst 0xc240118f // ldr c15, [x12, #4]
	.inst 0xc2401596 // ldr c22, [x12, #5]
	.inst 0xc240199b // ldr c27, [x12, #6]
	.inst 0xc2401d9c // ldr c28, [x12, #7]
	/* Vector registers */
	mrs x12, cptr_el3
	bfc x12, #10, #1
	msr cptr_el3, x12
	isb
	ldr q1, =0x0
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30850032
	msr SCTLR_EL3, x12
	ldr x12, =0xc
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x8260324c // ldr c12, [c18, #3]
	.inst 0xc28b412c // msr ddc_el3, c12
	isb
	.inst 0x8260124c // ldr c12, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr ddc_el3, c12
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400192 // ldr c18, [x12, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400592 // ldr c18, [x12, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400992 // ldr c18, [x12, #2]
	.inst 0xc2d2a4a1 // chkeq c5, c18
	b.ne comparison_fail
	.inst 0xc2400d92 // ldr c18, [x12, #3]
	.inst 0xc2d2a4e1 // chkeq c7, c18
	b.ne comparison_fail
	.inst 0xc2401192 // ldr c18, [x12, #4]
	.inst 0xc2d2a5c1 // chkeq c14, c18
	b.ne comparison_fail
	.inst 0xc2401592 // ldr c18, [x12, #5]
	.inst 0xc2d2a5e1 // chkeq c15, c18
	b.ne comparison_fail
	.inst 0xc2401992 // ldr c18, [x12, #6]
	.inst 0xc2d2a6c1 // chkeq c22, c18
	b.ne comparison_fail
	.inst 0xc2401d92 // ldr c18, [x12, #7]
	.inst 0xc2d2a761 // chkeq c27, c18
	b.ne comparison_fail
	.inst 0xc2402192 // ldr c18, [x12, #8]
	.inst 0xc2d2a781 // chkeq c28, c18
	b.ne comparison_fail
	.inst 0xc2402592 // ldr c18, [x12, #9]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0x0
	mov x18, v1.d[0]
	cmp x12, x18
	b.ne comparison_fail
	ldr x12, =0x0
	mov x18, v1.d[1]
	cmp x12, x18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000101a
	ldr x1, =check_data0
	ldr x2, =0x0000101c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001150
	ldr x1, =check_data1
	ldr x2, =0x00001152
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001a70
	ldr x1, =check_data2
	ldr x2, =0x00001a72
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff6
	ldr x1, =check_data3
	ldr x2, =0x00001ff7
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400018
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400078
	ldr x1, =check_data5
	ldr x2, =0x00400084
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00440000
	ldr x1, =check_data6
	ldr x2, =0x00440008
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
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr ddc_el3, c12
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
