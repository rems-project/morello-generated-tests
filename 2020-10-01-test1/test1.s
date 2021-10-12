.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x0d
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x60, 0x52, 0xc2, 0xc2
.data
check_data4:
	.byte 0x6e, 0xc2, 0xcb, 0x38, 0x82, 0xd6, 0x3f, 0x39, 0x2a, 0x7c, 0x9f, 0x08, 0xf6, 0x4f, 0x5a, 0xf8
	.byte 0xc0, 0x13, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0xa1, 0x30, 0xc2, 0xc2, 0x5f, 0x38, 0x3b, 0xe2, 0x86, 0x07, 0x3c, 0x5c, 0xc1, 0x13, 0xc1, 0xc2
	.byte 0x40, 0x12, 0xc2, 0xc2
.data
check_data7:
	.zero 8
.data
check_data8:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x200d
	/* C5 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C19 */
	.octa 0x20008000000100060000000000401008
	/* C20 */
	.octa 0x60c
	/* C30 */
	.octa 0xa0008000000300070000000000414bb9
final_cap_values:
	/* C1 */
	.octa 0x400000000000
	/* C2 */
	.octa 0x200d
	/* C5 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C19 */
	.octa 0x20008000000100060000000000401008
	/* C20 */
	.octa 0x60c
	/* C22 */
	.octa 0x0
	/* C30 */
	.octa 0xa0008000000300070000000000414bb9
initial_csp_value:
	.octa 0x480004
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200740800000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000203000700ffe00000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c25260 // RET-C-C 00000:00000 Cn:19 100:100 opc:10 11000010110000100:11000010110000100
	.zero 4100
	.inst 0x38cbc26e // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:14 Rn:19 00:00 imm9:010111100 0:0 opc:11 111000:111000 size:00
	.inst 0x393fd682 // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:20 imm12:111111110101 opc:00 111001:111001 size:00
	.inst 0x089f7c2a // stllrb:aarch64/instrs/memory/ordered Rt:10 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xf85a4ff6 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:22 Rn:31 11:11 imm9:110100100 0:0 opc:01 111000:111000 size:11
	.inst 0xc2c213c0 // BR-C-C 00000:00000 Cn:30 100:100 opc:00 11000010110000100:11000010110000100
	.zero 80796
	.inst 0xc2c230a1 // CHKTGD-C-C 00001:00001 Cn:5 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xe23b385f // ASTUR-V.RI-Q Rt:31 Rn:2 op2:10 imm9:110110011 V:1 op1:00 11100010:11100010
	.inst 0x5c3c0786 // ldr_lit_fpsimd:aarch64/instrs/memory/literal/simdfp Rt:6 imm19:0011110000000111100 011100:011100 opc:01
	.inst 0xc2c113c1 // GCLIM-R.C-C Rd:1 Cn:30 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0xc2c21240
	.zero 963636
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x21, cptr_el3
	orr x21, x21, #0x200
	msr cptr_el3, x21
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a1 // ldr c1, [x21, #0]
	.inst 0xc24006a2 // ldr c2, [x21, #1]
	.inst 0xc2400aa5 // ldr c5, [x21, #2]
	.inst 0xc2400eaa // ldr c10, [x21, #3]
	.inst 0xc24012b3 // ldr c19, [x21, #4]
	.inst 0xc24016b4 // ldr c20, [x21, #5]
	.inst 0xc2401abe // ldr c30, [x21, #6]
	/* Vector registers */
	mrs x21, cptr_el3
	bfc x21, #10, #1
	msr cptr_el3, x21
	isb
	ldr q31, =0x2000000000000000000000000
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =initial_csp_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2c1d2bf // cpy c31, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	ldr x21, =0x0
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82603255 // ldr c21, [c18, #3]
	.inst 0xc28b4135 // msr ddc_el3, c21
	isb
	.inst 0x82601255 // ldr c21, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr ddc_el3, c21
	isb
	/* Check processor flags */
	mrs x21, nzcv
	ubfx x21, x21, #28, #4
	mov x18, #0xf
	and x21, x21, x18
	cmp x21, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002b2 // ldr c18, [x21, #0]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc24006b2 // ldr c18, [x21, #1]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400ab2 // ldr c18, [x21, #2]
	.inst 0xc2d2a4a1 // chkeq c5, c18
	b.ne comparison_fail
	.inst 0xc2400eb2 // ldr c18, [x21, #3]
	.inst 0xc2d2a541 // chkeq c10, c18
	b.ne comparison_fail
	.inst 0xc24012b2 // ldr c18, [x21, #4]
	.inst 0xc2d2a5c1 // chkeq c14, c18
	b.ne comparison_fail
	.inst 0xc24016b2 // ldr c18, [x21, #5]
	.inst 0xc2d2a661 // chkeq c19, c18
	b.ne comparison_fail
	.inst 0xc2401ab2 // ldr c18, [x21, #6]
	.inst 0xc2d2a681 // chkeq c20, c18
	b.ne comparison_fail
	.inst 0xc2401eb2 // ldr c18, [x21, #7]
	.inst 0xc2d2a6c1 // chkeq c22, c18
	b.ne comparison_fail
	.inst 0xc24022b2 // ldr c18, [x21, #8]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x21, =0x0
	mov x18, v6.d[0]
	cmp x21, x18
	b.ne comparison_fail
	ldr x21, =0x0
	mov x18, v6.d[1]
	cmp x21, x18
	b.ne comparison_fail
	ldr x21, =0x0
	mov x18, v31.d[0]
	cmp x21, x18
	b.ne comparison_fail
	ldr x21, =0x200000000
	mov x18, v31.d[1]
	cmp x21, x18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001601
	ldr x1, =check_data1
	ldr x2, =0x00001602
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fc0
	ldr x1, =check_data2
	ldr x2, =0x00001fd0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400004
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00401008
	ldr x1, =check_data4
	ldr x2, =0x0040101c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004010c4
	ldr x1, =check_data5
	ldr x2, =0x004010c5
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00414bb8
	ldr x1, =check_data6
	ldr x2, =0x00414bcc
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x0047ffa8
	ldr x1, =check_data7
	ldr x2, =0x0047ffb0
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x0048ccb0
	ldr x1, =check_data8
	ldr x2, =0x0048ccb8
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
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr ddc_el3, c21
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
