.section data0, #alloc, #write
	.zero 3264
	.byte 0xf0, 0x2c, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x37, 0x0a, 0x06, 0x10, 0x00, 0x80, 0x00, 0x20
	.zero 816
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0xf0, 0x2c, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x37, 0x0a, 0x06, 0x10, 0x00, 0x80, 0x00, 0x20
.data
check_data3:
	.byte 0xdf, 0x13, 0xc2, 0x3c, 0xe0, 0x3b, 0x4d, 0x82, 0xfd, 0x2b, 0xde, 0xc2, 0xc0, 0x03, 0x3f, 0xd6
.data
check_data4:
	.byte 0xb2, 0xca, 0xa2, 0x78, 0x4e, 0xf9, 0xcc, 0xc2, 0x40, 0x90, 0xd9, 0xc2
.data
check_data5:
	.byte 0x80, 0x02, 0x3f, 0xd6
.data
check_data6:
	.byte 0xc2, 0x98, 0xc2, 0xb6
.data
check_data7:
	.byte 0xe2, 0x0a, 0xc0, 0xda, 0x80, 0x13, 0xc2, 0xc2
.data
check_data8:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x90100000000300060000000000002000
	/* C10 */
	.octa 0xc00000000000000000000000
	/* C20 */
	.octa 0x1013
	/* C21 */
	.octa 0x800000000007800f0000000000406100
	/* C30 */
	.octa 0x8000000000270026000000000000108f
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C10 */
	.octa 0xc00000000000000000000000
	/* C14 */
	.octa 0xc19000000000000000000000
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x1013
	/* C21 */
	.octa 0x800000000007800f0000000000406100
	/* C29 */
	.octa 0x800000000000000000000cc8
	/* C30 */
	.octa 0x20008000c401f0010000000000400095
initial_SP_EL3_value:
	.octa 0x800000000000000000000cc8
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004401f0010000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000004001000400ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001cc0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3cc213df // ldur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:31 Rn:30 00:00 imm9:000100001 0:0 opc:11 111100:111100 size:00
	.inst 0x824d3be0 // ASTR-R.RI-32 Rt:0 Rn:31 op:10 imm9:011010011 L:0 1000001001:1000001001
	.inst 0xc2de2bfd // BICFLGS-C.CR-C Cd:29 Cn:31 1010:1010 opc:00 Rm:30 11000010110:11000010110
	.inst 0xd63f03c0 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:30 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 4
	.inst 0x78a2cab2 // ldrsh_reg:aarch64/instrs/memory/single/general/register Rt:18 Rn:21 10:10 S:0 option:110 Rm:2 1:1 opc:10 111000:111000 size:01
	.inst 0xc2ccf94e // SCBNDS-C.CI-S Cd:14 Cn:10 1110:1110 S:1 imm6:011001 11000010110:11000010110
	.inst 0xc2d99040 // BR-CI-C 0:0 0000:0000 Cn:2 100:100 imm7:1001100 110000101101:110000101101
	.zero 112
	.inst 0xd63f0280 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:20 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 11356
	.inst 0xb6c298c2 // tbz:aarch64/instrs/branch/conditional/test Rt:2 imm14:01010011000110 b40:11000 op:0 011011:011011 b5:1
	.zero 21268
	.inst 0xdac00ae2 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:2 Rn:23 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2c21380
	.zero 1015792
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x25, cptr_el3
	orr x25, x25, #0x200
	msr cptr_el3, x25
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
	ldr x25, =initial_cap_values
	.inst 0xc2400320 // ldr c0, [x25, #0]
	.inst 0xc2400722 // ldr c2, [x25, #1]
	.inst 0xc2400b2a // ldr c10, [x25, #2]
	.inst 0xc2400f34 // ldr c20, [x25, #3]
	.inst 0xc2401335 // ldr c21, [x25, #4]
	.inst 0xc240173e // ldr c30, [x25, #5]
	/* Set up flags and system registers */
	mov x25, #0x00000000
	msr nzcv, x25
	ldr x25, =initial_SP_EL3_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2c1d33f // cpy c31, c25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
	ldr x25, =0x88
	msr S3_6_C1_C2_2, x25 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82603399 // ldr c25, [c28, #3]
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	.inst 0x82601399 // ldr c25, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c21320 // br c25
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc240033c // ldr c28, [x25, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240073c // ldr c28, [x25, #1]
	.inst 0xc2dca541 // chkeq c10, c28
	b.ne comparison_fail
	.inst 0xc2400b3c // ldr c28, [x25, #2]
	.inst 0xc2dca5c1 // chkeq c14, c28
	b.ne comparison_fail
	.inst 0xc2400f3c // ldr c28, [x25, #3]
	.inst 0xc2dca641 // chkeq c18, c28
	b.ne comparison_fail
	.inst 0xc240133c // ldr c28, [x25, #4]
	.inst 0xc2dca681 // chkeq c20, c28
	b.ne comparison_fail
	.inst 0xc240173c // ldr c28, [x25, #5]
	.inst 0xc2dca6a1 // chkeq c21, c28
	b.ne comparison_fail
	.inst 0xc2401b3c // ldr c28, [x25, #6]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	.inst 0xc2401f3c // ldr c28, [x25, #7]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check vector registers */
	ldr x25, =0x0
	mov x28, v31.d[0]
	cmp x25, x28
	b.ne comparison_fail
	ldr x25, =0x0
	mov x28, v31.d[1]
	cmp x25, x28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001014
	ldr x1, =check_data0
	ldr x2, =0x00001018
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010b0
	ldr x1, =check_data1
	ldr x2, =0x000010c0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001cc0
	ldr x1, =check_data2
	ldr x2, =0x00001cd0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400010
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400014
	ldr x1, =check_data4
	ldr x2, =0x00400020
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400090
	ldr x1, =check_data5
	ldr x2, =0x00400094
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00402cf0
	ldr x1, =check_data6
	ldr x2, =0x00402cf4
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00408008
	ldr x1, =check_data7
	ldr x2, =0x00408010
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00408100
	ldr x1, =check_data8
	ldr x2, =0x00408102
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
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
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
