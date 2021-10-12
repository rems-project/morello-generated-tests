.section data0, #alloc, #write
	.zero 256
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 128
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02
	.zero 3680
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x82
.data
check_data1:
	.byte 0x02, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0xf1, 0xd3, 0xc5, 0xc2, 0xec, 0x6a, 0x4e, 0x7a, 0x66, 0xdf, 0xe8, 0x92, 0x82, 0x9b, 0x87, 0xb8
	.byte 0x1e, 0x66, 0x09, 0x78, 0xed, 0x6b, 0x40, 0x0b, 0x34, 0x70, 0x73, 0xe2, 0x41, 0x78, 0xaa, 0x02
	.byte 0xfe, 0x23, 0xd8, 0x3c, 0x5e, 0x48, 0x80, 0xac, 0x80, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40000000008700410000000000001801
	/* C16 */
	.octa 0x182
	/* C28 */
	.octa 0x1
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0xfffffffffffff564
	/* C2 */
	.octa 0x2
	/* C6 */
	.octa 0xb904ffffffffffff
	/* C16 */
	.octa 0x218
	/* C17 */
	.octa 0x0
	/* C28 */
	.octa 0x1
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x180
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005802108e0000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c5d3f1 // CVTDZ-C.R-C Cd:17 Rn:31 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0x7a4e6aec // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1100 0:0 Rn:23 10:10 cond:0110 imm5:01110 111010010:111010010 op:1 sf:0
	.inst 0x92e8df66 // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:6 imm16:0100011011111011 hw:11 100101:100101 opc:00 sf:1
	.inst 0xb8879b82 // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:28 10:10 imm9:001111001 0:0 opc:10 111000:111000 size:10
	.inst 0x7809661e // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:16 01:01 imm9:010010110 0:0 opc:00 111000:111000 size:01
	.inst 0x0b406bed // add_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:13 Rn:31 imm6:011010 Rm:0 0:0 shift:01 01011:01011 S:0 op:0 sf:0
	.inst 0xe2737034 // ASTUR-V.RI-H Rt:20 Rn:1 op2:00 imm9:100110111 V:1 op1:01 11100010:11100010
	.inst 0x02aa7841 // SUB-C.CIS-C Cd:1 Cn:2 imm12:101010011110 sh:0 A:1 00000010:00000010
	.inst 0x3cd823fe // ldur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:30 Rn:31 00:00 imm9:110000010 0:0 opc:11 111100:111100 size:00
	.inst 0xac80485e // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:30 Rn:2 Rt2:10010 imm7:0000000 L:0 1011001:1011001 opc:10
	.inst 0xc2c21080
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
	ldr x9, =initial_cap_values
	.inst 0xc2400121 // ldr c1, [x9, #0]
	.inst 0xc2400530 // ldr c16, [x9, #1]
	.inst 0xc240093c // ldr c28, [x9, #2]
	.inst 0xc2400d3e // ldr c30, [x9, #3]
	/* Vector registers */
	mrs x9, cptr_el3
	bfc x9, #10, #1
	msr cptr_el3, x9
	isb
	ldr q18, =0x82000000000000000000000000000000
	ldr q20, =0x0
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =initial_SP_EL3_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2c1d13f // cpy c31, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x3085003a
	msr SCTLR_EL3, x9
	ldr x9, =0x4
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603089 // ldr c9, [c4, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x82601089 // ldr c9, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x4, #0xf
	and x9, x9, x4
	cmp x9, #0xc
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400124 // ldr c4, [x9, #0]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400524 // ldr c4, [x9, #1]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400924 // ldr c4, [x9, #2]
	.inst 0xc2c4a4c1 // chkeq c6, c4
	b.ne comparison_fail
	.inst 0xc2400d24 // ldr c4, [x9, #3]
	.inst 0xc2c4a601 // chkeq c16, c4
	b.ne comparison_fail
	.inst 0xc2401124 // ldr c4, [x9, #4]
	.inst 0xc2c4a621 // chkeq c17, c4
	b.ne comparison_fail
	.inst 0xc2401524 // ldr c4, [x9, #5]
	.inst 0xc2c4a781 // chkeq c28, c4
	b.ne comparison_fail
	.inst 0xc2401924 // ldr c4, [x9, #6]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0x0
	mov x4, v18.d[0]
	cmp x9, x4
	b.ne comparison_fail
	ldr x9, =0x8200000000000000
	mov x4, v18.d[1]
	cmp x9, x4
	b.ne comparison_fail
	ldr x9, =0x0
	mov x4, v20.d[0]
	cmp x9, x4
	b.ne comparison_fail
	ldr x9, =0x0
	mov x4, v20.d[1]
	cmp x9, x4
	b.ne comparison_fail
	ldr x9, =0x0
	mov x4, v30.d[0]
	cmp x9, x4
	b.ne comparison_fail
	ldr x9, =0x200000000000000
	mov x4, v30.d[1]
	cmp x9, x4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001090
	ldr x1, =check_data0
	ldr x2, =0x000010b0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001108
	ldr x1, =check_data1
	ldr x2, =0x0000110c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001190
	ldr x1, =check_data2
	ldr x2, =0x000011a0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001210
	ldr x1, =check_data3
	ldr x2, =0x00001212
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001738
	ldr x1, =check_data4
	ldr x2, =0x0000173a
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
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
