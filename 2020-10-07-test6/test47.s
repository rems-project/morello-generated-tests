.section data0, #alloc, #write
	.zero 32
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4048
.data
check_data0:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 8
.data
check_data6:
	.byte 0x1e, 0x7c, 0xdf, 0x88, 0xc4, 0x7f, 0x9f, 0x08, 0xc0, 0x7f, 0xdf, 0xc8, 0x44, 0xc8, 0xdc, 0x2c
	.byte 0xdd, 0x22, 0xd3, 0x38, 0x02, 0xa3, 0x90, 0x38, 0x1f, 0x11, 0xc0, 0xc2, 0xc0, 0x7f, 0x9f, 0x88
	.byte 0xeb, 0x63, 0x58, 0xb1, 0xa2, 0xba, 0x5a, 0x82, 0x40, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xfa0
	/* C2 */
	.octa 0x1f74
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x500070000000000000000
	/* C21 */
	.octa 0x4000000057040ffc0000000000001000
	/* C22 */
	.octa 0x108c
	/* C24 */
	.octa 0x1fb4
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x500070000000000000000
	/* C21 */
	.octa 0x4000000057040ffc0000000000001000
	/* C22 */
	.octa 0x108c
	/* C24 */
	.octa 0x1fb4
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004100dc0c0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000007000b0000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x88df7c1e // ldlar:aarch64/instrs/memory/ordered Rt:30 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0x089f7fc4 // stllrb:aarch64/instrs/memory/ordered Rt:4 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc8df7fc0 // ldlar:aarch64/instrs/memory/ordered Rt:0 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0x2cdcc844 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:4 Rn:2 Rt2:10010 imm7:0111001 L:1 1011001:1011001 opc:00
	.inst 0x38d322dd // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:29 Rn:22 00:00 imm9:100110010 0:0 opc:11 111000:111000 size:00
	.inst 0x3890a302 // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:24 00:00 imm9:100001010 0:0 opc:10 111000:111000 size:00
	.inst 0xc2c0111f // GCBASE-R.C-C Rd:31 Cn:8 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x889f7fc0 // stllr:aarch64/instrs/memory/ordered Rt:0 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0xb15863eb // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:11 Rn:31 imm12:011000011000 sh:1 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0x825abaa2 // ASTR-R.RI-32 Rt:2 Rn:21 op:10 imm9:110101011 L:0 1000001001:1000001001
	.inst 0xc2c21340
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x18, cptr_el3
	orr x18, x18, #0x200
	msr cptr_el3, x18
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400642 // ldr c2, [x18, #1]
	.inst 0xc2400a44 // ldr c4, [x18, #2]
	.inst 0xc2400e48 // ldr c8, [x18, #3]
	.inst 0xc2401255 // ldr c21, [x18, #4]
	.inst 0xc2401656 // ldr c22, [x18, #5]
	.inst 0xc2401a58 // ldr c24, [x18, #6]
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30850032
	msr SCTLR_EL3, x18
	ldr x18, =0x4
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603352 // ldr c18, [c26, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x82601352 // ldr c18, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc240025a // ldr c26, [x18, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240065a // ldr c26, [x18, #1]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400a5a // ldr c26, [x18, #2]
	.inst 0xc2daa481 // chkeq c4, c26
	b.ne comparison_fail
	.inst 0xc2400e5a // ldr c26, [x18, #3]
	.inst 0xc2daa501 // chkeq c8, c26
	b.ne comparison_fail
	.inst 0xc240125a // ldr c26, [x18, #4]
	.inst 0xc2daa6a1 // chkeq c21, c26
	b.ne comparison_fail
	.inst 0xc240165a // ldr c26, [x18, #5]
	.inst 0xc2daa6c1 // chkeq c22, c26
	b.ne comparison_fail
	.inst 0xc2401a5a // ldr c26, [x18, #6]
	.inst 0xc2daa701 // chkeq c24, c26
	b.ne comparison_fail
	.inst 0xc2401e5a // ldr c26, [x18, #7]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc240225a // ldr c26, [x18, #8]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0x0
	mov x26, v4.d[0]
	cmp x18, x26
	b.ne comparison_fail
	ldr x18, =0x0
	mov x26, v4.d[1]
	cmp x18, x26
	b.ne comparison_fail
	ldr x18, =0x0
	mov x26, v18.d[0]
	cmp x18, x26
	b.ne comparison_fail
	ldr x18, =0x0
	mov x26, v18.d[1]
	cmp x18, x26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001020
	ldr x1, =check_data0
	ldr x2, =0x00001024
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000103e
	ldr x1, =check_data1
	ldr x2, =0x0000103f
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001080
	ldr x1, =check_data2
	ldr x2, =0x00001088
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000016ac
	ldr x1, =check_data3
	ldr x2, =0x000016b0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f3e
	ldr x1, =check_data4
	ldr x2, =0x00001f3f
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ff4
	ldr x1, =check_data5
	ldr x2, =0x00001ffc
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
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
