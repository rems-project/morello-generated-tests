.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x1f, 0x20, 0x8d, 0xf8, 0x40, 0xc8, 0xbf, 0x78, 0xc0, 0x51, 0xc2, 0xc2
.data
check_data3:
	.byte 0x00, 0x10
.data
check_data4:
	.byte 0x05, 0x80, 0x62, 0xe2, 0xc5, 0x7e, 0x9f, 0x08, 0xdc, 0xac, 0xa3, 0xd8, 0x5f, 0x47, 0xc2, 0xc2
	.byte 0x19, 0x7c, 0xa0, 0x9b, 0x21, 0x30, 0xc2, 0xc2, 0x01, 0x79, 0x9f, 0xb8, 0x60, 0x10, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x8000000000010006000000000040f0d0
	/* C5 */
	.octa 0x0
	/* C8 */
	.octa 0x80000000000100050000000000440001
	/* C14 */
	.octa 0x20008000d00200000000000000410001
	/* C22 */
	.octa 0x40000000000100050000000000001ffe
	/* C26 */
	.octa 0x800000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x8000000000010006000000000040f0d0
	/* C5 */
	.octa 0x0
	/* C8 */
	.octa 0x80000000000100050000000000440001
	/* C14 */
	.octa 0x20008000d00200000000000000410001
	/* C22 */
	.octa 0x40000000000100050000000000001ffe
	/* C25 */
	.octa 0x1000000
	/* C26 */
	.octa 0x800000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000000006000200fffffffc000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf88d201f // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:0 00:00 imm9:011010010 0:0 opc:10 111000:111000 size:11
	.inst 0x78bfc840 // ldrsh_reg:aarch64/instrs/memory/single/general/register Rt:0 Rn:2 10:10 S:0 option:110 Rm:31 1:1 opc:10 111000:111000 size:01
	.inst 0xc2c251c0 // RET-C-C 00000:00000 Cn:14 100:100 opc:10 11000010110000100:11000010110000100
	.zero 61636
	.inst 0x00001000
	.zero 3884
	.inst 0xe2628005 // ASTUR-V.RI-H Rt:5 Rn:0 op2:00 imm9:000101000 V:1 op1:01 11100010:11100010
	.inst 0x089f7ec5 // stllrb:aarch64/instrs/memory/ordered Rt:5 Rn:22 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xd8a3acdc // prfm_lit:aarch64/instrs/memory/literal/general Rt:28 imm19:1010001110101100110 011000:011000 opc:11
	.inst 0xc2c2475f // CSEAL-C.C-C Cd:31 Cn:26 001:001 opc:10 0:0 Cm:2 11000010110:11000010110
	.inst 0x9ba07c19 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:25 Rn:0 Ra:31 o0:0 Rm:0 01:01 U:1 10011011:10011011
	.inst 0xc2c23021 // CHKTGD-C-C 00001:00001 Cn:1 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xb89f7901 // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:8 10:10 imm9:111110111 0:0 opc:10 111000:111000 size:10
	.inst 0xc2c21060
	.zero 983008
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a1 // ldr c1, [x13, #0]
	.inst 0xc24005a2 // ldr c2, [x13, #1]
	.inst 0xc24009a5 // ldr c5, [x13, #2]
	.inst 0xc2400da8 // ldr c8, [x13, #3]
	.inst 0xc24011ae // ldr c14, [x13, #4]
	.inst 0xc24015b6 // ldr c22, [x13, #5]
	.inst 0xc24019ba // ldr c26, [x13, #6]
	/* Vector registers */
	mrs x13, cptr_el3
	bfc x13, #10, #1
	msr cptr_el3, x13
	isb
	ldr q5, =0x0
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	ldr x13, =0x4
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x8260306d // ldr c13, [c3, #3]
	.inst 0xc28b412d // msr ddc_el3, c13
	isb
	.inst 0x8260106d // ldr c13, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr ddc_el3, c13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x3, #0xf
	and x13, x13, x3
	cmp x13, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001a3 // ldr c3, [x13, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc24005a3 // ldr c3, [x13, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc24009a3 // ldr c3, [x13, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400da3 // ldr c3, [x13, #3]
	.inst 0xc2c3a4a1 // chkeq c5, c3
	b.ne comparison_fail
	.inst 0xc24011a3 // ldr c3, [x13, #4]
	.inst 0xc2c3a501 // chkeq c8, c3
	b.ne comparison_fail
	.inst 0xc24015a3 // ldr c3, [x13, #5]
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	.inst 0xc24019a3 // ldr c3, [x13, #6]
	.inst 0xc2c3a6c1 // chkeq c22, c3
	b.ne comparison_fail
	.inst 0xc2401da3 // ldr c3, [x13, #7]
	.inst 0xc2c3a721 // chkeq c25, c3
	b.ne comparison_fail
	.inst 0xc24021a3 // ldr c3, [x13, #8]
	.inst 0xc2c3a741 // chkeq c26, c3
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x3, v5.d[0]
	cmp x13, x3
	b.ne comparison_fail
	ldr x13, =0x0
	mov x3, v5.d[1]
	cmp x13, x3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001028
	ldr x1, =check_data0
	ldr x2, =0x0000102a
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffe
	ldr x1, =check_data1
	ldr x2, =0x00001fff
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040000c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0040f0d0
	ldr x1, =check_data3
	ldr x2, =0x0040f0d2
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00410000
	ldr x1, =check_data4
	ldr x2, =0x00410020
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0043fff8
	ldr x1, =check_data5
	ldr x2, =0x0043fffc
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
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr ddc_el3, c13
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
