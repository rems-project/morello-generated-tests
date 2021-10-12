.section data0, #alloc, #write
	.zero 2048
	.byte 0x2a, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x2a, 0x00, 0x40, 0x00
.data
check_data4:
	.byte 0xca, 0xbf, 0x51, 0xb1, 0xfe, 0x05, 0x8f, 0xb8, 0xbf, 0xf8, 0x22, 0x78, 0x85, 0xcf, 0x0d, 0x78
	.byte 0x2d, 0x98, 0x08, 0xa8, 0xcc, 0x27, 0x6d, 0xe2, 0xec, 0x44, 0x61, 0xe2, 0x63, 0xad, 0xad, 0x92
	.byte 0x5e, 0x88, 0xab, 0x9b, 0x42, 0x08, 0xc0, 0xda, 0x00, 0x10, 0xc2, 0xc2
.data
check_data5:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40000000000700070000000000001038
	/* C2 */
	.octa 0x7c00000000000800
	/* C5 */
	.octa 0x40000000040700c60800000000000000
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0x400000
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0x80000000000300070000000000001800
	/* C28 */
	.octa 0x40000000610000040000000000000f40
final_cap_values:
	/* C1 */
	.octa 0x40000000000700070000000000001038
	/* C2 */
	.octa 0x7c00080000
	/* C3 */
	.octa 0xffffffff9294ffff
	/* C5 */
	.octa 0x40000000040700c60800000000000000
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0x400000
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0x800000000003000700000000000018f0
	/* C28 */
	.octa 0x4000000061000004000000000000101c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000100794060000000000400000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb151bfca // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:10 Rn:30 imm12:010001101111 sh:1 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0xb88f05fe // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:15 01:01 imm9:011110000 0:0 opc:10 111000:111000 size:10
	.inst 0x7822f8bf // strh_reg:aarch64/instrs/memory/single/general/register Rt:31 Rn:5 10:10 S:1 option:111 Rm:2 1:1 opc:00 111000:111000 size:01
	.inst 0x780dcf85 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:5 Rn:28 11:11 imm9:011011100 0:0 opc:00 111000:111000 size:01
	.inst 0xa808982d // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:13 Rn:1 Rt2:00110 imm7:0010001 L:0 1010000:1010000 opc:10
	.inst 0xe26d27cc // ALDUR-V.RI-H Rt:12 Rn:30 op2:01 imm9:011010010 V:1 op1:01 11100010:11100010
	.inst 0xe26144ec // ALDUR-V.RI-H Rt:12 Rn:7 op2:01 imm9:000010100 V:1 op1:01 11100010:11100010
	.inst 0x92adad63 // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:3 imm16:0110110101101011 hw:01 100101:100101 opc:00 sf:1
	.inst 0x9bab885e // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:30 Rn:2 Ra:2 o0:1 Rm:11 01:01 U:1 10011011:10011011
	.inst 0xdac00842 // rev:aarch64/instrs/integer/arithmetic/rev Rd:2 Rn:2 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2c21000
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x16, cptr_el3
	orr x16, x16, #0x200
	msr cptr_el3, x16
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
	ldr x16, =initial_cap_values
	.inst 0xc2400201 // ldr c1, [x16, #0]
	.inst 0xc2400602 // ldr c2, [x16, #1]
	.inst 0xc2400a05 // ldr c5, [x16, #2]
	.inst 0xc2400e06 // ldr c6, [x16, #3]
	.inst 0xc2401207 // ldr c7, [x16, #4]
	.inst 0xc240160d // ldr c13, [x16, #5]
	.inst 0xc2401a0f // ldr c15, [x16, #6]
	.inst 0xc2401e1c // ldr c28, [x16, #7]
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	ldr x16, =0x0
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x0, =pcc_return_ddc_capabilities
	.inst 0xc2400000 // ldr c0, [x0, #0]
	.inst 0x82603010 // ldr c16, [c0, #3]
	.inst 0xc28b4130 // msr ddc_el3, c16
	isb
	.inst 0x82601010 // ldr c16, [c0, #1]
	.inst 0x82602000 // ldr c0, [c0, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr ddc_el3, c16
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2c0a421 // chkeq c1, c0
	b.ne comparison_fail
	.inst 0xc2400600 // ldr c0, [x16, #1]
	.inst 0xc2c0a441 // chkeq c2, c0
	b.ne comparison_fail
	.inst 0xc2400a00 // ldr c0, [x16, #2]
	.inst 0xc2c0a461 // chkeq c3, c0
	b.ne comparison_fail
	.inst 0xc2400e00 // ldr c0, [x16, #3]
	.inst 0xc2c0a4a1 // chkeq c5, c0
	b.ne comparison_fail
	.inst 0xc2401200 // ldr c0, [x16, #4]
	.inst 0xc2c0a4c1 // chkeq c6, c0
	b.ne comparison_fail
	.inst 0xc2401600 // ldr c0, [x16, #5]
	.inst 0xc2c0a4e1 // chkeq c7, c0
	b.ne comparison_fail
	.inst 0xc2401a00 // ldr c0, [x16, #6]
	.inst 0xc2c0a5a1 // chkeq c13, c0
	b.ne comparison_fail
	.inst 0xc2401e00 // ldr c0, [x16, #7]
	.inst 0xc2c0a5e1 // chkeq c15, c0
	b.ne comparison_fail
	.inst 0xc2402200 // ldr c0, [x16, #8]
	.inst 0xc2c0a781 // chkeq c28, c0
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x27cc
	mov x0, v12.d[0]
	cmp x16, x0
	b.ne comparison_fail
	ldr x16, =0x0
	mov x0, v12.d[1]
	cmp x16, x0
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
	ldr x0, =0x0000101c
	ldr x1, =check_data1
	ldr x2, =0x0000101e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010c0
	ldr x1, =check_data2
	ldr x2, =0x000010d0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001804
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
	ldr x0, =0x004000fc
	ldr x1, =check_data5
	ldr x2, =0x004000fe
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
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr ddc_el3, c16
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
