.section data0, #alloc, #write
	.zero 624
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3456
.data
check_data0:
	.byte 0x10, 0x14
.data
check_data1:
	.byte 0xc0, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0x22, 0x91, 0xc0, 0xc2, 0xfe, 0xd1, 0xbc, 0xca, 0x1e, 0xa4, 0x66, 0xa9, 0xe0, 0x7c, 0x9f, 0x48
	.byte 0xc0, 0x07, 0xc8, 0x3c, 0x20, 0x52, 0xc2, 0xc2
.data
check_data6:
	.byte 0x22, 0x48, 0x9e, 0x02, 0xe8, 0xff, 0x0f, 0xb8, 0x41, 0xe8, 0x9e, 0xea, 0x00, 0xc0, 0x66, 0xe2
	.byte 0x60, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1410
	/* C1 */
	.octa 0x120070000000000000000
	/* C7 */
	.octa 0x1000
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C17 */
	.octa 0x200080008001800600000000004c0029
final_cap_values:
	/* C0 */
	.octa 0x1410
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x12007fffffffffffff86e
	/* C7 */
	.octa 0x1000
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C17 */
	.octa 0x200080008001800600000000004c0029
	/* C30 */
	.octa 0x2040
initial_SP_EL3_value:
	.octa 0x40000000000500030000000000001431
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000a0080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000007fee04f80000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 96
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c09122 // GCTAG-R.C-C Rd:2 Cn:9 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0xcabcd1fe // eon:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:15 imm6:110100 Rm:28 N:1 shift:10 01010:01010 opc:10 sf:1
	.inst 0xa966a41e // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:30 Rn:0 Rt2:01001 imm7:1001101 L:1 1010010:1010010 opc:10
	.inst 0x489f7ce0 // stllrh:aarch64/instrs/memory/ordered Rt:0 Rn:7 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x3cc807c0 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:0 Rn:30 01:01 imm9:010000000 0:0 opc:11 111100:111100 size:00
	.inst 0xc2c25220 // RET-C-C 00000:00000 Cn:17 100:100 opc:10 11000010110000100:11000010110000100
	.zero 786448
	.inst 0x029e4822 // SUB-C.CIS-C Cd:2 Cn:1 imm12:011110010010 sh:0 A:1 00000010:00000010
	.inst 0xb80fffe8 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:8 Rn:31 11:11 imm9:011111111 0:0 opc:00 111000:111000 size:10
	.inst 0xea9ee841 // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:2 imm6:111010 Rm:30 N:0 shift:10 01010:01010 opc:11 sf:1
	.inst 0xe266c000 // ASTUR-V.RI-H Rt:0 Rn:0 op2:00 imm9:001101100 V:1 op1:01 11100010:11100010
	.inst 0xc2c21360
	.zero 262084
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x20, cptr_el3
	orr x20, x20, #0x200
	msr cptr_el3, x20
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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400681 // ldr c1, [x20, #1]
	.inst 0xc2400a87 // ldr c7, [x20, #2]
	.inst 0xc2400e88 // ldr c8, [x20, #3]
	.inst 0xc2401289 // ldr c9, [x20, #4]
	.inst 0xc2401691 // ldr c17, [x20, #5]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =initial_SP_EL3_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2c1d29f // cpy c31, c20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30850032
	msr SCTLR_EL3, x20
	ldr x20, =0x0
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82603374 // ldr c20, [c27, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x82601374 // ldr c20, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	/* Check processor flags */
	mrs x20, nzcv
	ubfx x20, x20, #28, #4
	mov x27, #0xf
	and x20, x20, x27
	cmp x20, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc240029b // ldr c27, [x20, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240069b // ldr c27, [x20, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc2400a9b // ldr c27, [x20, #2]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400e9b // ldr c27, [x20, #3]
	.inst 0xc2dba4e1 // chkeq c7, c27
	b.ne comparison_fail
	.inst 0xc240129b // ldr c27, [x20, #4]
	.inst 0xc2dba501 // chkeq c8, c27
	b.ne comparison_fail
	.inst 0xc240169b // ldr c27, [x20, #5]
	.inst 0xc2dba521 // chkeq c9, c27
	b.ne comparison_fail
	.inst 0xc2401a9b // ldr c27, [x20, #6]
	.inst 0xc2dba621 // chkeq c17, c27
	b.ne comparison_fail
	.inst 0xc2401e9b // ldr c27, [x20, #7]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x20, =0x0
	mov x27, v0.d[0]
	cmp x20, x27
	b.ne comparison_fail
	ldr x20, =0x0
	mov x27, v0.d[1]
	cmp x20, x27
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
	ldr x0, =0x00001278
	ldr x1, =check_data1
	ldr x2, =0x00001288
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000147c
	ldr x1, =check_data2
	ldr x2, =0x0000147e
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001530
	ldr x1, =check_data3
	ldr x2, =0x00001534
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fc0
	ldr x1, =check_data4
	ldr x2, =0x00001fd0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400018
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004c0028
	ldr x1, =check_data6
	ldr x2, =0x004c003c
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
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
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
