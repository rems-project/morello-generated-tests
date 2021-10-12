.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x20, 0x70, 0x9c, 0x78, 0x21, 0x31, 0xc2, 0xc2, 0x07, 0xd2, 0x58, 0xb8, 0xc2, 0x7f, 0xdf, 0x88
	.byte 0x2e, 0x7e, 0x03, 0x54
.data
check_data2:
	.byte 0x8d, 0x20
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x25, 0xdc, 0x46, 0x82, 0x7e, 0x2a, 0x1f, 0x6a, 0x5f, 0x98, 0xe0, 0xc2, 0x88, 0x91, 0xc0, 0xc2
	.byte 0x1e, 0xfc, 0xdf, 0xc8, 0x60, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40000000580000000000000000001300
	/* C5 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C16 */
	.octa 0x3000
	/* C30 */
	.octa 0x10fd
final_cap_values:
	/* C0 */
	.octa 0x208d
	/* C1 */
	.octa 0x40000000580000000000000000001300
	/* C2 */
	.octa 0x789c7020
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C16 */
	.octa 0x3000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002001c0050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000005f00ef030000000000402001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword final_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x789c7020 // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:1 00:00 imm9:111000111 0:0 opc:10 111000:111000 size:01
	.inst 0xc2c23121 // CHKTGD-C-C 00001:00001 Cn:9 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xb858d207 // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:7 Rn:16 00:00 imm9:110001101 0:0 opc:01 111000:111000 size:10
	.inst 0x88df7fc2 // ldlar:aarch64/instrs/memory/ordered Rt:2 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0x54037e2e // b_cond:aarch64/instrs/branch/conditional/cond cond:1110 0:0 imm19:0000001101111110001 01010100:01010100
	.zero 436
	.inst 0x208d0000
	.zero 28168
	.inst 0x8246dc25 // ASTR-R.RI-64 Rt:5 Rn:1 op:11 imm9:001101101 L:0 1000001001:1000001001
	.inst 0x6a1f2a7e // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:19 imm6:001010 Rm:31 N:0 shift:00 01010:01010 opc:11 sf:0
	.inst 0xc2e0985f // SUBS-R.CC-C Rd:31 Cn:2 100110:100110 Cm:0 11000010111:11000010111
	.inst 0xc2c09188 // GCTAG-R.C-C Rd:8 Cn:12 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0xc8dffc1e // ldar:aarch64/instrs/memory/ordered Rt:30 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0xc2c21360
	.zero 1019924
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x3, cptr_el3
	orr x3, x3, #0x200
	msr cptr_el3, x3
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
	ldr x3, =initial_cap_values
	.inst 0xc2400061 // ldr c1, [x3, #0]
	.inst 0xc2400465 // ldr c5, [x3, #1]
	.inst 0xc2400869 // ldr c9, [x3, #2]
	.inst 0xc2400c6c // ldr c12, [x3, #3]
	.inst 0xc2401070 // ldr c16, [x3, #4]
	.inst 0xc240147e // ldr c30, [x3, #5]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30850032
	msr SCTLR_EL3, x3
	ldr x3, =0x4
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82603363 // ldr c3, [c27, #3]
	.inst 0xc28b4123 // msr ddc_el3, c3
	isb
	.inst 0x82601363 // ldr c3, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr ddc_el3, c3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x27, #0xf
	and x3, x3, x27
	cmp x3, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240007b // ldr c27, [x3, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240047b // ldr c27, [x3, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc240087b // ldr c27, [x3, #2]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400c7b // ldr c27, [x3, #3]
	.inst 0xc2dba4a1 // chkeq c5, c27
	b.ne comparison_fail
	.inst 0xc240107b // ldr c27, [x3, #4]
	.inst 0xc2dba4e1 // chkeq c7, c27
	b.ne comparison_fail
	.inst 0xc240147b // ldr c27, [x3, #5]
	.inst 0xc2dba501 // chkeq c8, c27
	b.ne comparison_fail
	.inst 0xc240187b // ldr c27, [x3, #6]
	.inst 0xc2dba521 // chkeq c9, c27
	b.ne comparison_fail
	.inst 0xc2401c7b // ldr c27, [x3, #7]
	.inst 0xc2dba581 // chkeq c12, c27
	b.ne comparison_fail
	.inst 0xc240207b // ldr c27, [x3, #8]
	.inst 0xc2dba601 // chkeq c16, c27
	b.ne comparison_fail
	.inst 0xc240247b // ldr c27, [x3, #9]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001668
	ldr x1, =check_data0
	ldr x2, =0x00001670
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400014
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x004001ca
	ldr x1, =check_data2
	ldr x2, =0x004001cc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400f90
	ldr x1, =check_data3
	ldr x2, =0x00400f98
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00401e90
	ldr x1, =check_data4
	ldr x2, =0x00401e94
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00406fd4
	ldr x1, =check_data5
	ldr x2, =0x00406fec
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
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr ddc_el3, c3
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
