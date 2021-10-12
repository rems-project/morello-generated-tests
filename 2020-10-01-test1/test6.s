.section data0, #alloc, #write
	.zero 224
	.byte 0x50, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3856
.data
check_data0:
	.zero 16
	.byte 0x50, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x20
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0x50, 0x20
.data
check_data6:
	.zero 2
.data
check_data7:
	.byte 0xe2, 0x7f, 0x9f, 0x08, 0xd6, 0x6f, 0x97, 0xb8, 0x25, 0x20, 0x42, 0x7a, 0x5e, 0xd0, 0xc5, 0x62
	.byte 0xfe, 0xd7, 0xbe, 0xe2, 0xd6, 0x59, 0x47, 0x78, 0x5f, 0x64, 0xc2, 0xc2, 0x14, 0x72, 0x48, 0xe2
	.byte 0x87, 0x7a, 0x5d, 0xa2, 0x34, 0xa0, 0x94, 0x6d, 0xe0, 0x12, 0xc2, 0xc2
.data
check_data8:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x1020
	/* C14 */
	.octa 0x1f81
	/* C16 */
	.octa 0x40000000000100050000000000001f0d
	/* C30 */
	.octa 0x500002
final_cap_values:
	/* C1 */
	.octa 0x1148
	/* C2 */
	.octa 0x10d0
	/* C7 */
	.octa 0x0
	/* C14 */
	.octa 0x1f81
	/* C16 */
	.octa 0x40000000000100050000000000001f0d
	/* C20 */
	.octa 0x2050
	/* C22 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0x8000000000010005000000000000180b
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc01000000003000700ffe00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001dc0
	.dword initial_cap_values + 48
	.dword final_cap_values + 64
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x089f7fe2 // stllrb:aarch64/instrs/memory/ordered Rt:2 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xb8976fd6 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:22 Rn:30 11:11 imm9:101110110 0:0 opc:10 111000:111000 size:10
	.inst 0x7a422025 // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0101 0:0 Rn:1 00:00 cond:0010 Rm:2 111010010:111010010 op:1 sf:0
	.inst 0x62c5d05e // LDP-C.RIBW-C Ct:30 Rn:2 Ct2:10100 imm7:0001011 L:1 011000101:011000101
	.inst 0xe2bed7fe // ALDUR-V.RI-S Rt:30 Rn:31 op2:01 imm9:111101101 V:1 op1:10 11100010:11100010
	.inst 0x784759d6 // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:22 Rn:14 10:10 imm9:001110101 0:0 opc:01 111000:111000 size:01
	.inst 0xc2c2645f // CPYVALUE-C.C-C Cd:31 Cn:2 001:001 opc:11 0:0 Cm:2 11000010110:11000010110
	.inst 0xe2487214 // ASTURH-R.RI-32 Rt:20 Rn:16 op2:00 imm9:010000111 V:0 op1:01 11100010:11100010
	.inst 0xa25d7a87 // LDTR-C.RIB-C Ct:7 Rn:20 10:10 imm9:111010111 0:0 opc:01 10100010:10100010
	.inst 0x6d94a034 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:20 Rn:1 Rt2:01000 imm7:0101001 L:0 1011011:1011011 opc:01
	.inst 0xc2c212e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x9, cptr_el3
	orr x9, x9, #0x200
	msr cptr_el3, x9
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
	ldr x9, =initial_cap_values
	.inst 0xc2400121 // ldr c1, [x9, #0]
	.inst 0xc2400522 // ldr c2, [x9, #1]
	.inst 0xc240092e // ldr c14, [x9, #2]
	.inst 0xc2400d30 // ldr c16, [x9, #3]
	.inst 0xc240113e // ldr c30, [x9, #4]
	/* Vector registers */
	mrs x9, cptr_el3
	bfc x9, #10, #1
	msr cptr_el3, x9
	isb
	ldr q8, =0x0
	ldr q20, =0x0
	/* Set up flags and system registers */
	mov x9, #0x20000000
	msr nzcv, x9
	ldr x9, =initial_csp_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2c1d13f // cpy c31, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30850032
	msr SCTLR_EL3, x9
	ldr x9, =0x0
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032e9 // ldr c9, [c23, #3]
	.inst 0xc28b4129 // msr ddc_el3, c9
	isb
	.inst 0x826012e9 // ldr c9, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr ddc_el3, c9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x23, #0xf
	and x9, x9, x23
	cmp x9, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400137 // ldr c23, [x9, #0]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400537 // ldr c23, [x9, #1]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400937 // ldr c23, [x9, #2]
	.inst 0xc2d7a4e1 // chkeq c7, c23
	b.ne comparison_fail
	.inst 0xc2400d37 // ldr c23, [x9, #3]
	.inst 0xc2d7a5c1 // chkeq c14, c23
	b.ne comparison_fail
	.inst 0xc2401137 // ldr c23, [x9, #4]
	.inst 0xc2d7a601 // chkeq c16, c23
	b.ne comparison_fail
	.inst 0xc2401537 // ldr c23, [x9, #5]
	.inst 0xc2d7a681 // chkeq c20, c23
	b.ne comparison_fail
	.inst 0xc2401937 // ldr c23, [x9, #6]
	.inst 0xc2d7a6c1 // chkeq c22, c23
	b.ne comparison_fail
	.inst 0xc2401d37 // ldr c23, [x9, #7]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0x0
	mov x23, v8.d[0]
	cmp x9, x23
	b.ne comparison_fail
	ldr x9, =0x0
	mov x23, v8.d[1]
	cmp x9, x23
	b.ne comparison_fail
	ldr x9, =0x0
	mov x23, v20.d[0]
	cmp x9, x23
	b.ne comparison_fail
	ldr x9, =0x0
	mov x23, v20.d[1]
	cmp x9, x23
	b.ne comparison_fail
	ldr x9, =0x0
	mov x23, v30.d[0]
	cmp x9, x23
	b.ne comparison_fail
	ldr x9, =0x0
	mov x23, v30.d[1]
	cmp x9, x23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010d0
	ldr x1, =check_data0
	ldr x2, =0x000010f0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001148
	ldr x1, =check_data1
	ldr x2, =0x00001158
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017f8
	ldr x1, =check_data2
	ldr x2, =0x000017fc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000180b
	ldr x1, =check_data3
	ldr x2, =0x0000180c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001dc0
	ldr x1, =check_data4
	ldr x2, =0x00001dd0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001f94
	ldr x1, =check_data5
	ldr x2, =0x00001f96
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001ff6
	ldr x1, =check_data6
	ldr x2, =0x00001ff8
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400000
	ldr x1, =check_data7
	ldr x2, =0x0040002c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x004fff78
	ldr x1, =check_data8
	ldr x2, =0x004fff7c
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
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr ddc_el3, c9
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
