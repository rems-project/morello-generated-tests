.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x18, 0xc8, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x02, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x3e, 0x53, 0x50, 0x35, 0xed, 0xa7, 0x1f, 0xe2, 0x41, 0x4c, 0x02, 0xa2, 0xfe, 0xdf, 0x8e, 0xb8
	.byte 0x59, 0xee, 0x40, 0x6c, 0x9f, 0x9f, 0x45, 0xf9, 0x1f, 0x41, 0x3e, 0x4b, 0x3d, 0x50, 0xa2, 0x82
	.byte 0x02, 0x14, 0xb5, 0xe2, 0x2a, 0x2b, 0x5f, 0x82, 0x60, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 1
.data
check_data7:
	.zero 4
.data
check_data8:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2003
	/* C1 */
	.octa 0x400000000002ffffffffffffc818
	/* C2 */
	.octa 0x48000000080704570000000000001000
	/* C10 */
	.octa 0x0
	/* C18 */
	.octa 0x80000000580403240000000000000ff8
	/* C25 */
	.octa 0x1438
	/* C28 */
	.octa 0x800000004c0220070000000000404038
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x2003
	/* C1 */
	.octa 0x400000000002ffffffffffffc818
	/* C2 */
	.octa 0x48000000080704570000000000001240
	/* C10 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C18 */
	.octa 0x80000000580403240000000000000ff8
	/* C25 */
	.octa 0x1438
	/* C28 */
	.octa 0x800000004c0220070000000000404038
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0x80000000000040000000000000402003
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000006000500ffffffffffa280
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3550533e // cbnz:aarch64/instrs/branch/conditional/compare Rt:30 imm19:0101000001010011001 op:1 011010:011010 sf:0
	.inst 0xe21fa7ed // ALDURB-R.RI-32 Rt:13 Rn:31 op2:01 imm9:111111010 V:0 op1:00 11100010:11100010
	.inst 0xa2024c41 // STR-C.RIBW-C Ct:1 Rn:2 11:11 imm9:000100100 0:0 opc:00 10100010:10100010
	.inst 0xb88edffe // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:31 11:11 imm9:011101101 0:0 opc:10 111000:111000 size:10
	.inst 0x6c40ee59 // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:25 Rn:18 Rt2:11011 imm7:0000001 L:1 1011000:1011000 opc:01
	.inst 0xf9459f9f // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:28 imm12:000101100111 opc:01 111001:111001 size:11
	.inst 0x4b3e411f // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:31 Rn:8 imm3:000 option:010 Rm:30 01011001:01011001 S:0 op:1 sf:0
	.inst 0x82a2503d // ASTR-R.RRB-32 Rt:29 Rn:1 opc:00 S:1 option:010 Rm:2 1:1 L:0 100000101:100000101
	.inst 0xe2b51402 // ALDUR-V.RI-S Rt:2 Rn:0 op2:01 imm9:101010001 V:1 op1:10 11100010:11100010
	.inst 0x825f2b2a // ASTR-R.RI-32 Rt:10 Rn:25 op:10 imm9:111110010 L:0 1000001001:1000001001
	.inst 0xc2c21260
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x11, cptr_el3
	orr x11, x11, #0x200
	msr cptr_el3, x11
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400561 // ldr c1, [x11, #1]
	.inst 0xc2400962 // ldr c2, [x11, #2]
	.inst 0xc2400d6a // ldr c10, [x11, #3]
	.inst 0xc2401172 // ldr c18, [x11, #4]
	.inst 0xc2401579 // ldr c25, [x11, #5]
	.inst 0xc240197c // ldr c28, [x11, #6]
	.inst 0xc2401d7d // ldr c29, [x11, #7]
	.inst 0xc240217e // ldr c30, [x11, #8]
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =initial_csp_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2c1d17f // cpy c31, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30850032
	msr SCTLR_EL3, x11
	ldr x11, =0x4
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x8260326b // ldr c11, [c19, #3]
	.inst 0xc28b412b // msr ddc_el3, c11
	isb
	.inst 0x8260126b // ldr c11, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr ddc_el3, c11
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400173 // ldr c19, [x11, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc2400573 // ldr c19, [x11, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400973 // ldr c19, [x11, #2]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400d73 // ldr c19, [x11, #3]
	.inst 0xc2d3a541 // chkeq c10, c19
	b.ne comparison_fail
	.inst 0xc2401173 // ldr c19, [x11, #4]
	.inst 0xc2d3a5a1 // chkeq c13, c19
	b.ne comparison_fail
	.inst 0xc2401573 // ldr c19, [x11, #5]
	.inst 0xc2d3a641 // chkeq c18, c19
	b.ne comparison_fail
	.inst 0xc2401973 // ldr c19, [x11, #6]
	.inst 0xc2d3a721 // chkeq c25, c19
	b.ne comparison_fail
	.inst 0xc2401d73 // ldr c19, [x11, #7]
	.inst 0xc2d3a781 // chkeq c28, c19
	b.ne comparison_fail
	.inst 0xc2402173 // ldr c19, [x11, #8]
	.inst 0xc2d3a7a1 // chkeq c29, c19
	b.ne comparison_fail
	.inst 0xc2402573 // ldr c19, [x11, #9]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x0
	mov x19, v2.d[0]
	cmp x11, x19
	b.ne comparison_fail
	ldr x11, =0x0
	mov x19, v2.d[1]
	cmp x11, x19
	b.ne comparison_fail
	ldr x11, =0x0
	mov x19, v25.d[0]
	cmp x11, x19
	b.ne comparison_fail
	ldr x11, =0x0
	mov x19, v25.d[1]
	cmp x11, x19
	b.ne comparison_fail
	ldr x11, =0x0
	mov x19, v27.d[0]
	cmp x11, x19
	b.ne comparison_fail
	ldr x11, =0x0
	mov x19, v27.d[1]
	cmp x11, x19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001118
	ldr x1, =check_data1
	ldr x2, =0x0000111c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001240
	ldr x1, =check_data2
	ldr x2, =0x00001250
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001c00
	ldr x1, =check_data3
	ldr x2, =0x00001c04
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f54
	ldr x1, =check_data4
	ldr x2, =0x00001f58
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
	ldr x0, =0x00401ffd
	ldr x1, =check_data6
	ldr x2, =0x00401ffe
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004020f0
	ldr x1, =check_data7
	ldr x2, =0x004020f4
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00404b70
	ldr x1, =check_data8
	ldr x2, =0x00404b78
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr ddc_el3, c11
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
