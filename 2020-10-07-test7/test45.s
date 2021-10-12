.section data0, #alloc, #write
	.zero 2080
	.byte 0x6e, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2000
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x6e, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data5:
	.byte 0x62, 0x02, 0x20, 0x9b, 0xff, 0x37, 0x54, 0xe2, 0x5f, 0x7c, 0xc0, 0x9b, 0xcf, 0x03, 0x1a, 0xda
	.byte 0x02, 0xe8, 0x0f, 0xe2, 0x21, 0x42, 0xf8, 0x28, 0x13, 0x91, 0x86, 0x3c, 0x29, 0x2c, 0x37, 0xe2
	.byte 0x3a, 0x46, 0x93, 0xe2, 0x82, 0x6a, 0x2b, 0xeb, 0xa0, 0x13, 0xc2, 0xc2
.data
check_data6:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xf20
	/* C8 */
	.octa 0x40000000000710070000000000000f97
	/* C17 */
	.octa 0x8000000010070c0f0000000000001820
final_cap_values:
	/* C0 */
	.octa 0xf20
	/* C1 */
	.octa 0x40406e
	/* C8 */
	.octa 0x40000000000710070000000000000f97
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x8000000010070c0f00000000000017e0
	/* C26 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1101
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000780000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000000000000760004000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9b200262 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:2 Rn:19 Ra:0 o0:0 Rm:0 01:01 U:0 10011011:10011011
	.inst 0xe25437ff // ALDURH-R.RI-32 Rt:31 Rn:31 op2:01 imm9:101000011 V:0 op1:01 11100010:11100010
	.inst 0x9bc07c5f // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:31 Rn:2 Ra:11111 0:0 Rm:0 10:10 U:1 10011011:10011011
	.inst 0xda1a03cf // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:15 Rn:30 000000:000000 Rm:26 11010000:11010000 S:0 op:1 sf:1
	.inst 0xe20fe802 // ALDURSB-R.RI-64 Rt:2 Rn:0 op2:10 imm9:011111110 V:0 op1:00 11100010:11100010
	.inst 0x28f84221 // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:1 Rn:17 Rt2:10000 imm7:1110000 L:1 1010001:1010001 opc:00
	.inst 0x3c869113 // stur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:19 Rn:8 00:00 imm9:001101001 0:0 opc:10 111100:111100 size:00
	.inst 0xe2372c29 // ALDUR-V.RI-Q Rt:9 Rn:1 op2:11 imm9:101110010 V:1 op1:00 11100010:11100010
	.inst 0xe293463a // ALDUR-R.RI-32 Rt:26 Rn:17 op2:01 imm9:100110100 V:0 op1:10 11100010:11100010
	.inst 0xeb2b6a82 // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:2 Rn:20 imm3:010 option:011 Rm:11 01011001:01011001 S:1 op:1 sf:1
	.inst 0xc2c213a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x22, cptr_el3
	orr x22, x22, #0x200
	msr cptr_el3, x22
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c8 // ldr c8, [x22, #1]
	.inst 0xc2400ad1 // ldr c17, [x22, #2]
	/* Vector registers */
	mrs x22, cptr_el3
	bfc x22, #10, #1
	msr cptr_el3, x22
	isb
	ldr q19, =0x0
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =initial_SP_EL3_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2c1d2df // cpy c31, c22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	ldr x22, =0x4
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033b6 // ldr c22, [c29, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x826013b6 // ldr c22, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002dd // ldr c29, [x22, #0]
	.inst 0xc2dda401 // chkeq c0, c29
	b.ne comparison_fail
	.inst 0xc24006dd // ldr c29, [x22, #1]
	.inst 0xc2dda421 // chkeq c1, c29
	b.ne comparison_fail
	.inst 0xc2400add // ldr c29, [x22, #2]
	.inst 0xc2dda501 // chkeq c8, c29
	b.ne comparison_fail
	.inst 0xc2400edd // ldr c29, [x22, #3]
	.inst 0xc2dda601 // chkeq c16, c29
	b.ne comparison_fail
	.inst 0xc24012dd // ldr c29, [x22, #4]
	.inst 0xc2dda621 // chkeq c17, c29
	b.ne comparison_fail
	.inst 0xc24016dd // ldr c29, [x22, #5]
	.inst 0xc2dda741 // chkeq c26, c29
	b.ne comparison_fail
	/* Check vector registers */
	ldr x22, =0x0
	mov x29, v9.d[0]
	cmp x22, x29
	b.ne comparison_fail
	ldr x22, =0x0
	mov x29, v9.d[1]
	cmp x22, x29
	b.ne comparison_fail
	ldr x22, =0x0
	mov x29, v19.d[0]
	cmp x22, x29
	b.ne comparison_fail
	ldr x22, =0x0
	mov x29, v19.d[1]
	cmp x22, x29
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
	ldr x0, =0x0000101e
	ldr x1, =check_data1
	ldr x2, =0x0000101f
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001044
	ldr x1, =check_data2
	ldr x2, =0x00001046
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001714
	ldr x1, =check_data3
	ldr x2, =0x00001718
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001820
	ldr x1, =check_data4
	ldr x2, =0x00001828
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
	ldr x0, =0x00403fe0
	ldr x1, =check_data6
	ldr x2, =0x00403ff0
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
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
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
